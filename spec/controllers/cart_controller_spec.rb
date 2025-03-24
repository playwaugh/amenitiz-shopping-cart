require 'rails_helper'

RSpec.describe CartController, type: :controller do
  describe "POST #add" do
    it "adds a product to the cart" do
      post :add, params: { product_code: 'GR1' }

      expect(session[:cart]).to eq([ 'GR1' ])
      expect(flash[:notice]).to eq('GR1 added to cart')
      expect(response).to redirect_to(root_path)
    end

    it "adds a product to an existing cart" do
      session[:cart] = [ 'SR1' ]

      post :add, params: { product_code: 'GR1' }

      expect(session[:cart]).to eq([ 'SR1', 'GR1' ])
      expect(flash[:notice]).to eq('GR1 added to cart')
      expect(response).to redirect_to(root_path)
    end
  end

  describe "DELETE #remove" do
    it "removes a product from the cart by index" do
      session[:cart] = [ 'GR1', 'SR1', 'CF1' ]

      delete :remove, params: { index: 1 }

      expect(session[:cart]).to eq([ 'GR1', 'CF1' ])
      expect(flash[:notice]).to eq('Item removed from cart')
      expect(response).to redirect_to(root_path)
    end

    it "handles removal of non-existent index" do
      session[:cart] = [ 'GR1', 'SR1' ]

      delete :remove, params: { index: 5 }

      expect(session[:cart]).to eq([ 'GR1', 'SR1' ])
      expect(flash[:notice]).to eq('Item removed from cart')
      expect(response).to redirect_to(root_path)
    end

    it "handles removal from empty cart" do
      session[:cart] = nil

      delete :remove, params: { index: 0 }

      expect(session[:cart]).to be_nil
      expect(flash[:notice]).to eq('Item removed from cart')
      expect(response).to redirect_to(root_path)
    end
  end

  describe "DELETE #clear" do
    it "clears the cart" do
      session[:cart] = [ 'GR1', 'SR1', 'CF1' ]

      delete :clear

      expect(session[:cart]).to eq([])
      expect(flash[:notice]).to eq('Cart cleared')
      expect(response).to redirect_to(root_path)
    end

    it "works on an already empty cart" do
      session[:cart] = []

      delete :clear

      expect(session[:cart]).to eq([])
      expect(flash[:notice]).to eq('Cart cleared')
      expect(response).to redirect_to(root_path)
    end

    it "works when cart is nil" do
      session[:cart] = nil

      delete :clear

      expect(session[:cart]).to eq([])
      expect(flash[:notice]).to eq('Cart cleared')
      expect(response).to redirect_to(root_path)
    end
  end
end
