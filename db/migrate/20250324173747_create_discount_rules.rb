class CreateDiscountRules < ActiveRecord::Migration[7.2]
  def change
    create_table :discount_rules do |t|
      t.string :name
      t.string :rule_type
      t.integer :min_quantity
      t.integer :free_quantity
      t.decimal :new_unit_price
      t.decimal :discount_percentage
      t.references :product, null: false, foreign_key: true

      t.timestamps
    end
  end
end
