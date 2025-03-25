class BogofDiscountCalculator < DiscountCalculator
  def calculate(product, quantity, rule)
    items_to_pay_for = (quantity / (1 + (rule.free_quantity || 1).to_f)).ceil
    product.price * items_to_pay_for
  end
end
