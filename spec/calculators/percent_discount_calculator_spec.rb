require 'rails_helper'

RSpec.describe PercentDiscountCalculator do
  describe "#calculate" do
    let(:product) { instance_double("Product", price: 11.23) }

    it "applies percentage discount correctly" do
      rule = instance_double("DiscountRule", discount_percentage: 33.33)
      result = subject.calculate(product, 3, rule)
      expect(result).to be_within(0.01).of(22.46)
    end

    it "scales with quantity" do
      rule = instance_double("DiscountRule", discount_percentage: 33.33)
      result = subject.calculate(product, 4, rule)
      expect(result).to be_within(0.01).of(29.95)
    end
  end
end
