require 'rails_helper'

RSpec.describe DiscountCalculator do
  describe "#calculate" do
    let(:product) { instance_double("Product", price: 5.00) }

    it "calculates total price by multiplying product price and quantity" do
      result = subject.calculate(product, 3, nil)
      expect(result).to eq(15.00)
    end

    it "ignores the rule parameter" do
      rule = instance_double("DiscountRule", new_unit_price: 4.50)
      result = subject.calculate(product, 3, rule)
      expect(result).to eq(15.00)
    end

    it "works with different quantities" do
      result = subject.calculate(product, 4, nil)
      expect(result).to eq(20.00)
    end
  end
end
