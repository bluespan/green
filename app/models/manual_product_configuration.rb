class ManualProductConfiguration < ActiveRecord::Base

  acts_as_money :price, :currency => "USD", :amount => :price_in_cents
  acts_as_money :shipping, :currency => "USD", :amount => :shipping_in_cents
  
   alias_method :manual_price, :price
   alias_method :manual_shipping, :shipping

  
  belongs_to :product
  attr_accessor :options
  
  def options
    @options ||= product.options.configuration(option_ids.split(","))
  end
  
  def price
    price_manual? ? manual_price : original_price
  end
  
  def original_price
    options.sum(&:price) + product.base_price
  end
  
  def shipping
    shipping_manual? ? manual_shipping : original_shipping
  end
  
  def original_shipping
    options.sum(&:shipping) + product.base_shipping
  end
  
  
  def part_number
    product.base_part_number + options.map(&:part_number).join("")
  end
  
  def to_url
    return "" if options.size == 0
    "?#{options.collect{ |o| "configuration[#{o.attribute.downcase}][]=#{o.id}"}.join("&")}"
  end
end