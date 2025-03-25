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

  # Match the calculator names with your actual implementation
  let(:bogof_calculator) { instance_double(BogofDiscountCalculator) }
  let(:bulk_calculator) { instance_double(BulkDiscountCalculator) }
  let(:percentage_calculator) { instance_double(PercentDiscountCalculator) }
  let(:regular_calculator) { instance_double(RegularPriceCalculator) }

  before do
    allow(BogofDiscountCalculator).to receive(:new).and_return(bogof_calculator)
    allow(BulkDiscountCalculator).to receive(:new).and_return(bulk_calculator)
    allow(PercentDiscountCalculator).to receive(:new).and_return(percentage_calculator)
    allow(RegularPriceCalculator).to receive(:new).and_return(regular_calculator)

    allow(bogof_calculator).to receive(:calculate).and_return(3.11)
    allow(bulk_calculator).to receive(:calculate).and_return(13.50)
    allow(percentage_calculator).to receive(:calculate).and_return(22.46)
    allow(regular_calculator).to receive(:calculate) do |product, quantity, _rule|
      product.price * quantity
    end

    products_relation = double("ProductsRelation")
    allow(Product).to receive(:includes).and_return(products_relation)
    allow(products_relation).to receive(:index_by).and_return({
      "GR1" => green_tea,
      "SR1" => strawberries,
      "CF1" => coffee
    })
  end

  describe "#calculate_total" do
    context "with empty basket" do
      it "returns zero" do
        expect(checkout.calculate_total([])).to eq(0)
      end
    end

    context "with a single product" do
      it "uses regular price for one item" do
        expect(checkout.calculate_total(["GR1"])).to eq(3.11)
        expect(regular_calculator).not_to have_received(:calculate)
      end
    end

    context "with multiple items eligible for discount" do
      it "calls the appropriate calculator for BOGOF" do
        allow(bogof_calculator).to receive(:calculate).with(green_tea, 2, green_tea_rule).and_return(3.11)

        checkout.calculate_total(["GR1", "GR1"])

        expect(bogof_calculator).to have_received(:calculate).with(green_tea, 2, green_tea_rule)
      end

      it "calls the appropriate calculator for bulk price" do
        allow(bulk_calculator).to receive(:calculate).with(strawberries, 3, strawberry_rule).and_return(13.50)

        checkout.calculate_total(["SR1", "SR1", "SR1"])

        expect(bulk_calculator).to have_received(:calculate).with(strawberries, 3, strawberry_rule)
      end

      it "calls the appropriate calculator for percentage discount" do
        allow(percentage_calculator).to receive(:calculate).with(coffee, 3, coffee_rule).and_return(22.46)

        checkout.calculate_total(["CF1", "CF1", "CF1"])

        expect(percentage_calculator).to have_received(:calculate).with(coffee, 3, coffee_rule)
      end
    end

    context "with mixed items" do
      it "calculates the correct total with multiple discount types" do
        # SR1, SR1, GR1, SR1
        allow(bogof_calculator).to receive(:calculate).with(green_tea, 1, anything).and_return(3.11)
        allow(bulk_calculator).to receive(:calculate).with(strawberries, 3, strawberry_rule).and_return(13.50)

        result = checkout.calculate_total(["SR1", "SR1", "GR1", "SR1"])

        expect(result).to eq(16.61)
      end
    end
  end

  describe "#count_items" do
    it "correctly counts occurrences of each item" do
      result = checkout.send(:count_items, ["GR1", "SR1", "GR1", "CF1", "CF1"])
      expect(result).to eq({"GR1" => 2, "SR1" => 1, "CF1" => 2})
    end

    it "returns an empty hash for an empty array" do
      result = checkout.send(:count_items, [])
      expect(result).to eq({})
    end
  end
end
