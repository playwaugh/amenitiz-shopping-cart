require 'rails_helper'

RSpec.describe BulkDiscountCalculator do
  describe "#calculate" do
    let(:product) { instance_double("Product", price: 5.00) }

    it "uses the new unit price instead of product price" do
      rule = instance_double("DiscountRule", new_unit_price: 4.50)
      result = subject.calculate(product, 3, rule)
      expect(result).to eq(13.50)
    end

    it "scales with quantity" do
      rule = instance_double("DiscountRule", new_unit_price: 4.50)
      result = subject.calculate(product, 4, rule)
      expect(result).to eq(18.00)
    end
  end
end
