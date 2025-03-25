  class PercentDiscountCalculator < DiscountCalculator
    def calculate(product, quantity, rule)
      discount_multiplier = 1 - (rule.discount_percentage / 100)
      product.price * quantity * discount_multiplier
    end
  end
