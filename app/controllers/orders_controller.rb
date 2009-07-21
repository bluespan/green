class OrdersController < CheckoutController
  unloadable
  
  filter_parameter_logging :credit_card_number, :credit_card_cvv2, :credit_card_month, :credit_card_year, :credit_card_type
  before_filter :validate_cart_not_empty, :load_checkout_logic, :only => :create
  
  def show
    @order = Order.find(:first, :conditions => ["order_number = ?", params[:id]])
    render :template => "orders/not_found" if @order.nil?
  end
  
  def create
    @order ||= Order.new(params[:order])
    @order.cart = @cart
    @order.transaction_params ||= {:ip => request.remote_ip }
    if @order.save
      unintialize_cart
      return true
    else
      return false 
    end
  end

protected
  def ssl_required?
    true if Rails.env.production?
  end

private

  def render_show
    render :action => "show"
  end
  
  def load_page
    @page = PageTypes::Order.new
    @page.title = "Order"
  end

end