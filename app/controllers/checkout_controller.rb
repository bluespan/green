class CheckoutController < GreenController
  unloadable
  
  
  helper :pages
  before_filter :initialize_cart, :validate_cart_not_empty, :load_checkout_logic, :load_page

  def index
    checkout_goto_current_step
  end
 
protected
  def ssl_required?
    true if Rails.env.production?
  end
 
private
  include Span::Blue::Routing

  def load_page
    @page = PageTypes::Cart.instance
    @page.title = "Checkout"
  end

  def load_checkout_logic
    @checkout_logic = CheckoutLogic.new(@cart.checkout_state)
  end
  
  def checkout_next_step!
    @checkout_logic.next!
  end
  
  def checkout_redirect_from(state)
    state == @checkout_logic.state ? checkout_goto_next_step : checkout_goto_current_step
  end
    
  def checkout_goto_next_step
    checkout_next_step!
    checkout_goto_current_step
  end
  
  def checkout_goto_current_step
    @cart.update_attribute(:checkout_state, @checkout_logic.state.to_s)
    redirect_to @checkout_logic.checkout_url
  end
  
  def validate_cart_not_empty
    if @cart.quantity == 0
      flash[:cart] = "You must add items to your cart before you checkout."
      redirect_to cart_index_url 
    end
  end
  

end