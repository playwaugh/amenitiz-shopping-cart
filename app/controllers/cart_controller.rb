class CartController < ApplicationController
  def add
    product_code = params[:product_code]

    session[:cart] ||= []
    session[:cart] << product_code

    redirect_to root_path, notice: "#{product_code} added to cart"
  end

  def remove
    index = params[:index].to_i
    session[:cart].delete_at(index) if session[:cart] && index < session[:cart].length

    redirect_to root_path, notice: "Item removed from cart"
  end

  def clear
    session[:cart] = []
    redirect_to root_path, notice: "Cart cleared"
  end
end
