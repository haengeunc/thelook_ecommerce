view: wide_table {
  derived_table: {
    sql_trigger_value: SELECT MAX(DATE(created_at)) FROM `@{bigquery_project}.@{bigquery_dataset}.events` ;;
    publish_as_db_view: yes
    explore_source: order_items {
      column: inventory_items_cost { field: inventory_items.cost }
      column: order_items_created_date { field: order_items.created_date }
      column: order_items_sale_price { field: order_items.sale_price }
      column: order_items_status { field: order_items.status }
      column: products_brand { field: products.brand }
      column: products_category { field: products.category }
      column: products_cost { field: products.cost }
      column: products_department { field: products.department }
      column: products_name { field: products.name }
      column: products_retail_price { field: products.retail_price }
      column: products_sku { field: products.sku }
      column: users_age { field: users.age }
      column: users_city { field: users.city }
      column: users_country { field: users.country }
      column: users_created_date { field: users.created_date }
      column: users_email { field: users.email }
      column: users_first_name { field: users.first_name }
      column: users_gender { field: users.gender }
      column: users_users_id { field: users.id }
      column: users_last_name { field: users.last_name }
      column: users_postal_code { field: users.postal_code }
      column: users_state { field: users.state }
      column: users_street_address { field: users.street_address }
      column: users_traffic_source { field: users.traffic_source }
      filters: {
        field: order_items.created_date
        value: "-NULL"
      }
    }
  }
  dimension: inventory_items_cost {type: number}
  dimension: order_items_created_date {type: date}
  dimension: order_items_sale_price {type: number}
  dimension: order_items_status {}
  dimension: products_brand {}
  dimension: products_category {}
  dimension: products_cost {type: number}
  dimension: products_department {}
  dimension: products_name {}
  dimension: products_retail_price {type: number}
  dimension: products_sku {}
  dimension: users_age {type: number}
  dimension: users_city {}
  dimension: users_country {}
  dimension: users_created_date {type: date}
  dimension: users_email {}
  dimension: users_first_name {}
  dimension: users_gender {}
  dimension: users_users_id {}
  dimension: users_last_name {}
  dimension: users_postal_code {}
  dimension: users_state {}
  dimension: users_street_address {}
  dimension: users_traffic_source {}
  measure: count {type: count}
}
