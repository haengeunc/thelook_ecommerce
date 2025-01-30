connection: "default_bigquery_connection"

label: "eCommerce [DEMO]"

include: "/views/demo/*.view" # include demo views

explore: wide_table {
  hidden: yes
}

explore: order_items {
  label: "Orders, Items and Users"
  view_name: order_items

  join: inventory_items {
    type: full_outer
    relationship: one_to_one
    sql_on: ${inventory_items.id} = ${order_items.inventory_item_id} ;;
  }
  join: users {
    type: left_outer
    relationship: many_to_one
    sql_on: ${order_items.user_id} = ${users.id} ;;
  }
  join: products {
    type: left_outer
    relationship: many_to_one
    sql_on: ${products.id} = ${inventory_items.product_id} ;;
  }
}
