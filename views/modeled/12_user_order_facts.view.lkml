view: user_order_facts {
  view_label: "Users"
  derived_table: {
    sql:
    SELECT
        user_id
        , COUNT(DISTINCT order_id) AS lifetime_orders
        , SUM(sale_price) AS lifetime_revenue
        , CAST(MIN(created_at)  AS TIMESTAMP) AS first_order
        , CAST(MAX(created_at)  AS TIMESTAMP)  AS latest_order
        , COUNT(DISTINCT FORMAT_TIMESTAMP('%Y%m', created_at))  AS number_of_distinct_months_with_orders
        --, FIRST_VALUE(CONCAT(uniform(2, 9, random(1)),uniform(0, 9, random(2)),uniform(0, 9, random(3)),'-',uniform(0, 9, random(4)),uniform(0, 9, random(5)),uniform(0, 9, random(6)),'-',uniform(0, 9, random(7)),uniform(0, 9, random(8)),uniform(0, 9, random(9)),uniform(0, 9, random(10)))) OVER (PARTITION BY user_id ORDER BY user_id) AS phone_number
      FROM @{bigquery_project}.@{bigquery_dataset}.order_items
      GROUP BY user_id
    ;;
    datagroup_trigger: thelook_prod_etl
  }

  dimension: user_id {
    label: "User ID"
    primary_key: yes
    hidden: yes
    sql: ${TABLE}.user_id ;;
  }

#   dimension: phone_number {
#     type: string
#     tags: ["phone"]
#     sql: ${TABLE}.phone_number ;;
#   }


  ##### Time and Cohort Fields ######

  dimension_group: first_order {
    label: "First Order"
    type: time
    timeframes: [date, week, month, year]
    sql: ${TABLE}.first_order ;;
  }

  dimension_group: latest_order {
    label: "Latest Orders"
    type: time
    timeframes: [date, week, month, year]
    sql: ${TABLE}.latest_order ;;
  }

  dimension: is_active_customer {
    group_label: "Lifetime Profile"
    description: "Any customers who placed order in the last 90 days"
    synonyms: ["active customers", "live customers"]
    type: yesno
    sql: ${latest_order_date} >= DATE_ADD(CURRENT_DATE, INTERVAL -90 DAY) ;;
  }



  dimension: days_to_first_order {
    label: "Days to First Order (from Signup)"
    group_label: "Lifetime Profile"
    description: "Days between user account registration (users.created_raw) and their first order (first_order)"
    synonyms: ["time to first purchase", "signup to first order days", "onboarding conversion days"]
    type: number
    sql: TIMESTAMP_DIFF(${TABLE}.first_order, ${users.created_raw}, DAY) ;;
  }

  dimension: purchased_within_30d_of_signup {
    label: "Purchased Within 30 Days of Signup"
    group_label: "Lifetime Profile"
    description: "Yes if the user placed their first order within 30 days of account registration"
    synonyms: ["new user 30d conversion", "converted within 30 days of registering"]
    type: yesno
    sql: TIMESTAMP_DIFF(${TABLE}.first_order, ${users.created_raw}, DAY) BETWEEN 0 AND 30 ;;
  }

  measure: count_users_purchased_within_30d {
    label: "Users Purchased Within 30 Days of Signup"
    group_label: "Lifetime Profile"
    description: "Count of registered users who placed their first purchase within 30 days of registering"
    synonyms: ["new users converted in 30 days", "30 day first purchase users"]
    type: count_distinct
    sql: ${users.id} ;;
    filters: {
      field: purchased_within_30d_of_signup
      value: "Yes"
    }
  }

  measure: first_purchase_within_30d_rate {
    label: "First Purchase Within 30 Days Rate"
    group_label: "Lifetime Profile"
    description: "Percentage of registered users who placed a first purchase within 30 days of registering"
    synonyms: ["new user 30-day conversion rate", "30d signup to purchase rate", "percentage of new users purchasing within 30 days"]
    type: number
    value_format_name: percent_1
    sql: 1.0 * ${count_users_purchased_within_30d} / NULLIF(${users.count_users}, 0) ;;
  }

  dimension: days_as_customer {
    label: "Days As Customer"
    description: "Days between first and latest order"
    type: number
    sql: TIMESTAMP_DIFF(${TABLE}.latest_order, ${TABLE}.first_order, DAY)+1 ;;
  }

  dimension: days_as_customer_tiered {
    label: "Days as Customer Tiered"
    type: tier
    tiers: [0, 1, 7, 14, 21, 28, 30, 60, 90, 120]
    sql: ${days_as_customer} ;;
    style: integer
  }

  ##### Lifetime Behavior - Order Counts ######

  dimension: lifetime_orders {
    label: "Lifetime Orders"
    group_label: "Lifetime Profile"
    type: number
    sql: ${TABLE}.lifetime_orders ;;
  }

  dimension: repeat_customer {
    label: "Repeat Customer"
    group_label: "Lifetime Profile"
    description: "Lifetime Count of Orders > 1"
    type: yesno
    sql: ${lifetime_orders} > 1 ;;
  }

  dimension: lifetime_orders_tier {
    label: "Lifetime Orders Tier"
    group_label: "Lifetime Profile"
    type: tier
    tiers: [0, 1, 2, 3, 5, 10]
    sql: ${lifetime_orders} ;;
    style: integer
  }

  measure: average_lifetime_orders {
    label: "Average Lifetime Orders"
    group_label: "Lifetime Profile"
    type: average
    value_format_name: decimal_2
    sql: ${lifetime_orders} ;;
  }

  dimension: distinct_months_with_orders {
    label: "Distinct Months with Orders"
    type: number
    sql: ${TABLE}.number_of_distinct_months_with_orders ;;
  }

  ##### Lifetime Behavior - Revenue ######

  dimension: lifetime_revenue {
    label: "Lifetime Revenue"
    description: "Total cumulative gross sales revenue generated by the customer across all orders"
    group_label: "Lifetime Profile"
    type: number
    value_format_name: usd
    sql: ${TABLE}.lifetime_revenue ;;
  }

  dimension: lifetime_revenue_tier {
    label: "Lifetime Revenue Tier"
    description: "Customer lifetime revenue bracket in USD ($0-$24 up to $1000+)"
    group_label: "Lifetime Profile"
    type: tier
    tiers: [0, 25, 50, 100, 200, 500, 1000]
    sql: ${lifetime_revenue} ;;
    style: integer
  }

  measure: average_lifetime_revenue {
    label: "Average Lifetime Revenue"
    description: "Average cumulative lifetime revenue per customer in USD"
    group_label: "Lifetime Profile"
    type: average
    value_format_name: usd
    sql: ${lifetime_revenue} ;;
  }
}
