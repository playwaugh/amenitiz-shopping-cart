class ProductsController < ApplicationController
  def index
    @products = Product.all
    @cart = session[:cart] || []
    @cart_items = []
    @total_price = 0

    unless @cart.empty?
      @cart_grouped = @cart.group_by { |product_code| product_code }.transform_values(&:count)

      @cart_grouped.each do |code, quantity|
        product = Product.find_by(code: code)
        next unless product

        @cart_items << {
          product: product,
          quantity: quantity
        }
      end

      checkout_service = CheckoutService.new
      @total_price = checkout_service.calculate_total(@cart)
    end
  end
end
