class DiscountRule < ApplicationRecord
  belongs_to :product

  validates :name, presence: true
  validates :rule_type, presence: true, inclusion: { in: [ "bogof", "bulk_price", "percent_discount" ] }
  validates :min_quantity, presence: true, numericality: { greater_than: 0 }
end
