class BulkDiscountCalculator < DiscountCalculator
  def calculate(product, quantity, rule)
    rule.new_unit_price * quantity
  end
end
