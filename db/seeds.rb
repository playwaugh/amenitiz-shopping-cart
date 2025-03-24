green_tea = Product.create!(code: 'GR1', name: 'Green Tea', price: 3.11)
strawberries = Product.create!(code: 'SR1', name: 'Strawberries', price: 5.00)
coffee = Product.create!(code: 'CF1', name: 'Coffee', price: 11.23)

green_tea.discount_rules.create!(
  name: 'Buy one get one free for Green Tea',
  rule_type: 'bogof',
  min_quantity: 2,
  free_quantity: 1
)

strawberries.discount_rules.create!(
  name: 'Bulk strawberry discount',
  rule_type: 'bulk_price',
  min_quantity: 3,
  new_unit_price: 4.50
)

coffee.discount_rules.create!(
  name: 'Coffee volume discount',
  rule_type: 'percent_discount',
  min_quantity: 3,
  discount_percentage: 33.33
)
