Rails.application.routes.draw do
  root "products#index"

  post "/cart/add", to: "cart#add", as: "add_to_cart"
  delete "/cart/remove/:index", to: "cart#remove", as: "remove_from_cart"
  delete "/cart/clear", to: "cart#clear", as: "clear_cart"
end
