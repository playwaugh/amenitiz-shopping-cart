class Product < ApplicationRecord
  has_many :discount_rules, dependent: :destroy

  validates :code, presence: true, uniqueness: true
  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
end
