class Order < ActiveRecord::Base
  unloadable
  
  acts_as_money :subtotal,  :currency => "USD", :amount => :subtotal_in_cents
  acts_as_money :shipping,  :currency => "USD", :amount => :shipping_in_cents
  acts_as_money :tax,       :currency => "USD", :amount => :tax_in_cents
  acts_as_money :total,     :currency => "USD", :amount => :total_in_cents
  
  acts_as_commentable
  include Span::RenderAnywhere
  
  has_many :line_items
  belongs_to :billing_address,  :class_name => "Address", :foreign_key => "billing_id"
  belongs_to :shipping_address, :class_name => "Address", :foreign_key => "shipping_id"
  
  has_many :transactions, 
           :class_name => "OrderTransaction", 
           :dependent => :destroy
  
  attr_internal :credit_card_cvv2, :cart
  
  validates_presence_of :email
  validates_presence_of :credit_card_type, :credit_card_number, :credit_card_month, :credit_card_year, :if => :require_credit_card_validation? 
  validates_presence_of :cart, :on => :create, :message => "needed" 

  validates_presence_of :billing_address, :on => :create, :message => "needed"
  validates_presence_of :shipping_address, :on => :create, :message => "needed"

  before_create :generate_order_number
  before_create :authorize
  before_create :hide_credit_card_number

  after_create :process_cart
  
  after_create :send_receipt
  after_create :notify_admin
  
  after_create :capture
  
  attr_accessor :transaction_params, :last_transaction, :require_credit_card_validation, :process_with_paypal_express
  
  def authorize
    if process_with_paypal_express?
      self.last_transaction = OrderTransaction.paypal_express_purchase(cart.total, transaction_params) 
    else
      self.last_transaction = OrderTransaction.authorize(cart.total, credit_card, transaction_params) 
    end
    
    if self.last_transaction.success? 
      transactions << self.last_transaction
      return true
    else
      errors.add(" ", self.last_transaction.message)
    end
    
    return false
  end
  
  def capture
    unless process_with_paypal_express?
      transactions << self.last_transaction = OrderTransaction.capture(self.total, transactions.authorizations.last.reference, transaction_params) 
    end
  end
  
  def process_cart

    if cart
      self.billing_id = cart.billing_id
      self.shipping_id = cart.shipping_id
      self.quantity = cart.quantity
      self.subtotal = cart.subtotal
      self.tax = cart.tax
      self.shipping = cart.shipping
      self.total = cart.total
      
      cart.line_items.each do |item|
        item.cart_id = nil
        line_items << item
      end
      
      cart.destroy
      save
    end
  end
  
  def credit_card
    return false if credit_card_number.blank?
    self.billing_id ||= cart.billing_id
    self.shipping_id ||= cart.shipping_id
    @credit_card ||= ActiveMerchant::Billing::CreditCard.new({ 
      :first_name => billing_address.firstname, 
      :last_name  => billing_address.lastname, 
      :number     => credit_card_number.to_s, 
      :month      => credit_card_month.to_s, 
      :year       => credit_card_year.to_s, 
      :verification_value => credit_card_cvv2.to_s
    }) 
  end
  
  def transaction_params
    self.billing_id ||= cart.billing_id
    self.shipping_id ||= cart.shipping_id
    @transaction_params ||= {}
    @transaction_params.update(
        :billing_address => {
          :name     => "#{billing_address.firstname} #{billing_address.lastname}", 
          :address1 => billing_address.street, 
          :address2 => billing_address.street2, 
          :city     => billing_address.city, 
          :state    => billing_address.state, 
          :country  => billing_address.country || 'US', 
          :zip      => billing_address.postal_code, 
          :phone    => billing_address.phone
        },
        :shipping_address => {
          :name     => "#{shipping_address.firstname} #{shipping_address.lastname}", 
          :address1 => shipping_address.street, 
          :address2 => shipping_address.street2, 
          :city     => shipping_address.city, 
          :state    => shipping_address.state, 
          :country  => shipping_address.country || 'US', 
          :zip      => shipping_address.postal_code, 
          :phone    => shipping_address.phone
        },
        :email => email
      )
  end
  
  def hide_credit_card_number
    unless credit_card_number.blank?
      self.credit_card_number = self.credit_card_number.gsub(/\D/, "").slice(/\d{4}$/) 
    end
  end
  
  def require_credit_card_validation?
    @require_credit_card_validation ||= (!process_with_paypal_express?)
  end
  
  def process_with_paypal_express?
    @process_with_paypal_express ||= false
  end
  
  def generate_order_number
    self.order_number ||= begin

      chars = ("0".."9").to_a
      
      begin
        random = ""
        1.upto(9) { |i| random << chars[rand(chars.size-1)] }
        record = Order.find(:first, :conditions => ["order_number = ?", random])
      end until record.nil?
      random
    end
  end
  
  def send_receipt
    comments << receipt = Comment.create({  :title => "Order ##{self.order_number} Receipt", 
                                            :comment => render({:file => 'orders/receipt.html.erb', :layout => false}, { :order => self })  })
    receipt.notify_with_email({ :recipients => self.email })
  end
  
  def notify_admin
    notification = Comment.new({  :title => "Order ##{self.order_number} Notification", 
                                            :comment => render({:file => 'orders/admin_notification.html.erb', :layout => false}, { :order => self })  })
    notification.notify_with_email({ :recipients => AdminUser.find(:all).collect {|user| user.email } })
  end
  
end