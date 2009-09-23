class Cart < ActiveRecord::Base
  unloadable
  
  has_many :line_items
  acts_as_money :subtotal, :currency => "USD", :amount => :subtotal_in_cents
  belongs_to :billing_address, :class_name => "Address", :foreign_key => "billing_id"
  belongs_to :shipping_address, :class_name => "Address", :foreign_key => "shipping_id"
  
  def add(product_id, options = {}, attachments = {})
    attachments = {} if attachments.nil?
    options.reverse_merge! :configuration => "", :quantity => 1, :product_id => product_id
    existing_item = line_items.find_by_product_id_and_configuration(product_id, options[:configuration])
  
    # Determine if attachments are empty
    attachments_empty = true
    attachments.each do |option_id, attachment|
      attachment.each do |option_id, value|
        attachments_empty = false unless value.empty?
      end
    end
  
    if existing_item.nil? or !attachments_empty
      item = create_new_item(product_id, options, attachments)
    else
      item = update_existing_item(existing_item, options[:quantity])
    end
  end

  
  def update_caches!
    self.quantity = line_items.collect(&:quantity).sum
    self.subtotal_in_cents = line_items.collect(&:subtotal).sum
    save!
  end
  
  def remove(line_item_id)
    line_items.destroy(line_item_id)
    update_caches!
  end
  
  def tax
    return 0.USD if billing_address.nil?
    subtotal * SalesTaxRate[billing_address.state].rate / 100 
  end

  def shipping
    0.USD
  end
  
  def total
    subtotal + tax + shipping
  end
  
  private
  
  def create_new_item(product_id, options = {}, attachments = {})
    product = Product.find(product_id)
    configuration = product.configuration[options[:configuration]]
    
    item = line_items.create( options.reverse_merge!(:price => configuration.price) )
    item.add_attachments(attachments) unless attachments.empty?
    update_caches!
    return item
  end
  
  def update_existing_item (existing_item, qty)
    existing_item.update_attribute(:quantity, existing_item.quantity += qty)
    update_caches!
    return existing_item
  end

end