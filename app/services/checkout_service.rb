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
        total += apply_discount(product, quantity, rule)
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

  def apply_discount(product, quantity, rule)
    case rule.rule_type
    when "bogof"
      items_to_pay_for = (quantity / (1 + (rule.free_quantity || 1).to_f)).ceil
      (product.price * items_to_pay_for).round(2)
    when "bulk_price"
      (rule.new_unit_price * quantity).round(2)
    when "percent_discount"
      discounted_price = product.price * (1 - (rule.discount_percentage / 100))
      (discounted_price * quantity).round(2)
    else
      (product.price * quantity).round(2)
    end
  end
end
