require "rails_helper"

RSpec.describe CheckoutService do
  let(:green_tea) { Product.create!(code: "GR1", name: "Green Tea", price: 3.11) }
  let(:strawberries) { Product.create!(code: "SR1", name: "Strawberries", price: 5.00) }
  let(:coffee) { Product.create!(code: "CF1", name: "Coffee", price: 11.23) }

  let!(:green_tea_rule) do
    DiscountRule.create!(
      product: green_tea,
      name: "Buy one get one free for Green Tea",
      rule_type: "bogof",
      min_quantity: 2,
      free_quantity: 1
    )
  end

  let!(:strawberry_rule) do
    DiscountRule.create!(
      product: strawberries,
      name: "Bulk strawberry discount",
      rule_type: "bulk_price",
      min_quantity: 3,
      new_unit_price: 4.50
    )
  end

  let!(:coffee_rule) do
    DiscountRule.create!(
      product: coffee,
      name: "Coffee volume discount",
      rule_type: "percent_discount",
      min_quantity: 3,
      discount_percentage: 33.33
    )
  end

  let(:checkout) { described_class.new }

  describe "#calculate_total" do
    context "with empty basket" do
      it "returns zero" do
        expect(checkout.calculate_total([])).to eq(0)
      end
    end

    context "with a single product" do
      before do
        allow(Product).to receive(:find_by).with(code: "GR1").and_return(green_tea)
        allow(Product).to receive(:find_by).with(code: "SR1").and_return(strawberries)
        allow(Product).to receive(:find_by).with(code: "CF1").and_return(coffee)
        allow(Product).to receive(:find_by).with(code: anything).and_return(nil)
      end

      it "calculates the regular price for one green tea" do
        expect(checkout.calculate_total([ "GR1" ])).to eq(3.11)
      end

      it "calculates the regular price for one strawberry" do
        expect(checkout.calculate_total([ "SR1" ])).to eq(5.00)
      end

      it "calculates the regular price for one coffee" do
        expect(checkout.calculate_total([ "CF1" ])).to eq(11.23)
      end
    end

    context "with BOGOF discount for Green Tea" do
      before do
        allow(Product).to receive(:find_by).with(code: "GR1").and_return(green_tea)
      end

      it "applies discount for two green teas" do
        expect(checkout.calculate_total([ "GR1", "GR1" ])).to eq(3.11)
      end

      it "applies discount for three green teas" do
        expect(checkout.calculate_total([ "GR1", "GR1", "GR1" ])).to eq(6.22)
      end

      it "applies discount for four green teas" do
        expect(checkout.calculate_total([ "GR1", "GR1", "GR1", "GR1" ])).to eq(6.22)
      end
    end

    context "with bulk discount for Strawberries" do
      before do
        allow(Product).to receive(:find_by).with(code: "SR1").and_return(strawberries)
      end

      it "applies regular price for two strawberries" do
        expect(checkout.calculate_total([ "SR1", "SR1" ])).to eq(10.00)
      end

      it "applies discount for three strawberries" do
        expect(checkout.calculate_total([ "SR1", "SR1", "SR1" ])).to eq(13.50)
      end

      it "applies discount for four strawberries" do
        expect(checkout.calculate_total([ "SR1", "SR1", "SR1", "SR1" ])).to eq(18.00)
      end
    end

    context "with percentage discount for Coffee" do
      before do
        allow(Product).to receive(:find_by).with(code: "CF1").and_return(coffee)
      end

      it "applies regular price for two coffees" do
        expect(checkout.calculate_total([ "CF1", "CF1" ])).to eq(22.46)
      end

      it "applies discount for three coffees" do
        expect(checkout.calculate_total([ "CF1", "CF1", "CF1" ])).to eq(22.46)
      end

      it "applies discount for four coffees" do
        expect(checkout.calculate_total([ "CF1", "CF1", "CF1", "CF1" ])).to eq(29.95)
      end
    end

    context "with mixed items" do
      before do
        allow(Product).to receive(:find_by).with(code: "GR1").and_return(green_tea)
        allow(Product).to receive(:find_by).with(code: "SR1").and_return(strawberries)
        allow(Product).to receive(:find_by).with(code: "CF1").and_return(coffee)
      end

      it "calculates the correct total for GR1, GR1" do
        expect(checkout.calculate_total([ "GR1", "GR1" ])).to eq(3.11)
      end

      it "calculates the correct total for SR1, SR1, GR1, SR1" do
        expect(checkout.calculate_total([ "SR1", "SR1", "GR1", "SR1" ])).to eq(16.61)
      end

      it "calculates the correct total for GR1, CF1, SR1, CF1, CF1" do
        expect(checkout.calculate_total([ "GR1", "CF1", "SR1", "CF1", "CF1" ])).to eq(30.57)
      end
    end

    context "with invalid product codes" do
      before do
        allow(Product).to receive(:find_by).with(code: "GR1").and_return(green_tea)
        allow(Product).to receive(:find_by).with(code: "INVALID").and_return(nil)
        allow(Product).to receive(:find_by).with(code: "NOTFOUND").and_return(nil)
      end

      it "ignores invalid product codes" do
        expect(checkout.calculate_total([ "INVALID", "GR1" ])).to eq(3.11)
      end

      it "returns zero for basket with only invalid codes" do
        expect(checkout.calculate_total([ "INVALID", "NOTFOUND" ])).to eq(0)
      end
    end
  end

  describe "#count_items" do
    it "correctly counts occurrences of each item" do
      result = checkout.send(:count_items, [ "GR1", "SR1", "GR1", "CF1", "CF1" ])
      expect(result).to eq({ "GR1" => 2, "SR1" => 1, "CF1" => 2 })
    end

    it "returns an empty hash for an empty array" do
      result = checkout.send(:count_items, [])
      expect(result).to eq({})
    end
  end

  describe "#apply_discount" do
    context "with BOGOF discount" do
      it "applies discount correctly" do
        result = checkout.send(:apply_discount, green_tea, 3, green_tea_rule)
        expect(result).to eq(6.22)
      end
    end

    context "with bulk price discount" do
      it "applies discount correctly" do
        result = checkout.send(:apply_discount, strawberries, 4, strawberry_rule)
        expect(result).to eq(18.00)
      end
    end

    context "with percentage discount" do
      it "applies discount correctly" do
        result = checkout.send(:apply_discount, coffee, 3, coffee_rule)
        expect(result).to eq(22.46)
      end
    end

    context "with unknown rule type" do
      it "falls back to regular price" do
        unknown_rule = instance_double("DiscountRule",
          rule_type: "unknown",
          min_quantity: 1
        )

        result = checkout.send(:apply_discount, green_tea, 2, unknown_rule)
        expect(result).to eq(6.22)
      end
    end
  end
end
