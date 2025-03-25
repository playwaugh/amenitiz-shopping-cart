
# Shopping Cart Application

## Overview

This Shopping Cart application is a demonstration of an e-commerce checkout system built with Ruby on Rails. It implements special pricing rules including buy-one-get-one-free offers, bulk discounts, and percentage-based discounts that can be easily configured or expanded on.

## 🚀 Features

- 📦 Product catalog
- 💡 Flexible discount rules
- 🛒 Interactive shopping cart
- 💰 Real-time price calculations with applied discounts
- 🖥️ Server-side rendered views with clean UI
- ✅ Comprehensive test suite

## 🛠 Technical Stack

- **Framework:** Ruby on Rails 7.2
- **Database:** PostgreSQL
- **Styling:** Tailwind CSS
- **Testing:** RSpec with rails-controller-testing

## 🏗 Domain Model

### Product Model
Represents items available for purchase with the following attributes:
- `code`: Unique identifier (e.g., "GR1")
- `name`: Human-readable product name
- `price`: Base price before any discounts

### DiscountRule Model
Represents pricing rules that can be applied to products:
- `rule_type`: Type of discount (bogof, bulk_price, percent_discount)
- `min_quantity`: Minimum quantity required to activate the rule
- `free_quantity`: Number of free items (for BOGOF rules)
- `new_unit_price`: New price per unit (for bulk price rules)
- `discount_percentage`: Discount percentage (for percentage-based discounts)
- Association with a specific product

## 🔧 Installation

### Prerequisites
- Ruby 3.2+
- Rails 7.2
- PostgreSQL

### Setup Steps
1. Clone the repository
   ```bash
   git clone https://github.com/yourusername/shopping-cart-app.git
   cd shopping-cart-app
   ```

2. Install dependencies
   ```bash
   bundle install
   ```

3. Setup database
   ```bash
   rails db:create
   rails db:migrate
   ```

4. Start the server
   ```bash
   rails server
   ```

## 🧪 Testing

Run the test suite with:
```bash
bundle exec rspec
```

## 💡 Discount Rule Examples

### Buy One Get One Free (BOGOF)
- Apply to green tea (GR1)
- When you buy one, you get another for free

### Bulk Discount
- Apply to strawberries (SR1)
- If you buy 3 or more, price reduces to €4.50 each

### Percentage Discount
- Apply to coffee (CF1)
- Apply a percentage discount for bulk purchases

## 💡 Adding New Discount Rules

### Locate the specific product by its unique code
```product = Product.find_by(code: 'PRODUCT_CODE')```

### Create a Discount Rule
```
  product.discount_rules.create!(
    name: 'New discount rule',
    rule_type: 'bogof',  # or 'bulk_price', 'percent_discount'
    min_quantity: 2,
    free_quantity: 1,     # for 'bogof'
    new_unit_price: 9.99, # for 'bulk_price'
    discount_percentage: 20 # for 'percent_discount'
  )
```
## 🛠 Design Decisions
### Using a Service Object for Checkout Logic
The checkout logic is encapsulated in a dedicated service object (CheckoutService) to:

Separate business logic from controllers
Make the code more testable
Allow for easier extension with new discount types

### Session-Based Cart
The cart is stored in the session rather than the database to:

- Simplify the implementation (no need for user accounts)
- Make the shopping experience faster
- Follow RESTful principles

### Model Relationships
Products have a one-to-many relationship with discount rules, allowing:

- Multiple types of discounts per product
- Clean separation of concerns
- Flexible configuration without code changes

### Future Improvements

- Admin interface for managing products and discount rules
- User accounts with saved carts
- More complex discount types (bundles, time-limited offers)
- Order history and checkout process
- API endpoints for headless commerce
