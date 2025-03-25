# app/services/checkout_service.rb
class CheckoutService
  def initialize
    @products = Product.includes(:discount_rules).index_by(&:code)
  end

  def calculate_total(basket_items)
    basket = count_items(basket_items)
    total = 0

    basket.each do |product_code, quantity|
      product = @products[product_code]
      next unless product

      applicable_rules = product.discount_rules.select { |rule| rule.min_quantity <= quantity }

      if applicable_rules.any?
        rule = applicable_rules.first
        total += discount_calculator_for(rule.rule_type).calculate(product, quantity, rule)
      else
        total += product.price * quantity
      end
    end

    total.round(2)
  end

  private

  def count_items(basket_items)
    basket = Hash.new(0)
    basket_items.each { |item| basket[item] += 1 }
    basket
  end

  def discount_calculator_for(rule_type)
    case rule_type
    when "bogof"
      BogofDiscountCalculator.new
    when "bulk_price"
      BulkDiscountCalculator.new
    when "percent_discount"
      PercentDiscountCalculator.new
    else
      RegularPriceCalculator.new
    end
  end
end
