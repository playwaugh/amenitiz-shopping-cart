require 'rails_helper'

RSpec.describe BogofDiscountCalculator do
  describe "#calculate" do
    let(:product) { instance_double("Product", price: 3.11) }

    it "calculates correct price for even number of items" do
      rule = instance_double("DiscountRule", free_quantity: 1)
      result = subject.calculate(product, 2, rule)
      expect(result).to eq(3.11)
    end

    it "calculates correct price for odd number of items" do
      rule = instance_double("DiscountRule", free_quantity: 1)
      result = subject.calculate(product, 3, rule)
      expect(result).to eq(6.22)
    end

    it "handles nil free_quantity" do
      rule = instance_double("DiscountRule", free_quantity: nil)
      result = subject.calculate(product, 2, rule)
      expect(result).to eq(3.11)
    end
  end
end
