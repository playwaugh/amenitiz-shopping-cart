require 'rails_helper'

RSpec.describe ProductsController, type: :controller do
  describe "GET #index" do
    let!(:green_tea) { Product.create!(code: 'GR1', name: 'Green Tea', price: 3.11) }
    let!(:strawberries) { Product.create!(code: 'SR1', name: 'Strawberries', price: 5.00) }
    let!(:coffee) { Product.create!(code: 'CF1', name: 'Coffee', price: 11.23) }

    before do
      DiscountRule.create!(
        product: green_tea,
        name: 'Buy one get one free for Green Tea',
        rule_type: 'bogof',
        min_quantity: 2,
        free_quantity: 1
      )

      DiscountRule.create!(
        product: strawberries,
        name: 'Bulk strawberry discount',
        rule_type: 'bulk_price',
        min_quantity: 3,
        new_unit_price: 4.50
      )

      DiscountRule.create!(
        product: coffee,
        name: 'Coffee volume discount',
        rule_type: 'percent_discount',
        min_quantity: 3,
        discount_percentage: 33.33
      )
    end

    context "with empty cart" do
      it "assigns all products to @products" do
        get :index
        expect(assigns(:products)).to match_array([green_tea, strawberries, coffee])
      end

      it "initializes empty cart" do
        get :index
        expect(assigns(:cart)).to eq([])
        expect(assigns(:cart_items)).to eq([])
        expect(assigns(:total_price)).to eq(0)
      end

      it "renders the index template" do
        get :index
        expect(response).to render_template("index")
      end
    end

    context "with items in cart" do
      before do
        session[:cart] = [ 'GR1', 'SR1', 'GR1' ]
        allow_any_instance_of(CheckoutService).to receive(:calculate_total).and_return(8.22)
      end

      it "assigns cart items correctly" do
        get :index

        expect(assigns(:cart)).to eq([ 'GR1', 'SR1', 'GR1' ])
        expect(assigns(:cart_grouped)).to eq({ 'GR1' => 2, 'SR1' => 1 })

        cart_items = assigns(:cart_items)
        expect(cart_items.length).to eq(2)

        expect(cart_items[0][:product]).to eq(green_tea)
        expect(cart_items[0][:quantity]).to eq(2)

        # Check second item (Strawberries)
        expect(cart_items[1][:product]).to eq(strawberries)
        expect(cart_items[1][:quantity]).to eq(1)
      end

      it "calculates total price using CheckoutService" do
        expect_any_instance_of(CheckoutService).to receive(:calculate_total).with([ 'GR1', 'SR1', 'GR1' ]).and_return(8.22)
        get :index
        expect(assigns(:total_price)).to eq(8.22)
      end
    end

    context "with non-existent product in cart" do
      before do
        session[:cart] = [ 'GR1', 'INVALID', 'SR1' ]
        allow_any_instance_of(CheckoutService).to receive(:calculate_total).and_return(8.11)
      end

      it "skips non-existent products" do
        get :index

        cart_items = assigns(:cart_items)
        expect(cart_items.length).to eq(2)

        product_codes = cart_items.map { |item| item[:product].code }
        expect(product_codes).to eq([ 'GR1', 'SR1' ])
        expect(product_codes).not_to include('INVALID')
      end
    end
  end
end
