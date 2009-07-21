map.connect "cart/checkout", :controller => "checkout", :action => "index" 

map.resources :cart, :controller => "cart", :collection => { :update_all => :put }
map.resources :orders

namespace :admin do |admin|
  admin.resource :catalog, :controller => "catalog"
  admin.connect 'products/:product_id/attributes/:attribute_name', :controller => 'attributes', :action => 'show'
  admin.connect 'products/:product_id/attributes/:attribute_name/options/:action.:format', :controller => 'options'
  admin.connect 'products/:product_id/attributes/:attribute_name/options/:action', :controller => 'options'
  admin.resources :products
  admin.resources :categories, :collection => { :move => :put }
  admin.resources :orders do |orders|
    orders.resources :notifications, :controller => "orders/notifications"
  end
  admin.resource :sales_tax_rates
  admin.connect "content/:action", :controller => "content"
  admin.connect "content", :controller => "content", :action => "index"
end
