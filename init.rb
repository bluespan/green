# Include hook code here
require 'rubygems'
require 'alter_ego'
gem 'activemerchant', "1.4.1"
require 'active_merchant'

require 'green'

ActiveRecord::Base.send :include, Span::Green::ProductMethods

