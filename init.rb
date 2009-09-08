# Include hook code here
require 'rubygems'
require 'alter_ego'
gem 'activemerchant', "1.4.1"
require 'active_merchant'

require 'green'

ActiveRecord::Base.send :include, Span::Green::ProductMethods
Span::Blue::Routing.send :include, Span::Green::Routing
ActionController::Base.send :include, GreenHelper
Admin::PagesHelper.send :include, GreenHelper::Admin::PagesHelper

config.to_prepare do
  Product.types ||= [ProductType::Simple]
  Page.types << PageTypes::Catalog  unless Page.types.include?(PageTypes::Catalog)
  Page.types << PageTypes::Cart  unless Page.types.include?(PageTypes::Cart)
end


