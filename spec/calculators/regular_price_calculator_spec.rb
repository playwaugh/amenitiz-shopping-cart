require 'rails_helper'

RSpec.describe RegularPriceCalculator do
  describe "#calculate" do
    let(:product) { instance_double("Product", price: 10.00) }
    let(:rule) { instance_double("DiscountRule") }

    it "calculates regular price" do
      result = subject.calculate(product, 3, rule)
      expect(result).to eq(30.00)
    end
  end
end
