class CartController < GreenController
  unloadable
  
  helper :pages
  before_filter :initialize_cart
  
  def index
    @page = PageTypes::Cart.instance
    render route
  end
  
  def create
    configuration = params[:product][:configuration].to_a.collect{ |attribute, option| option }.join(",")
    item = @cart.add(params[:product][:id], { :configuration => configuration }, params[:product][:attachments] )

    flash_msg = "A #{item.product.name} <span class='description'>#{item.product.configuration}</span> has been added to the cart."
    flash[:cart] = flash_msg
    redirect_to :action => :index
  end
  
  def update_all
    @cart.line_items.each do |item|
      if params[:line_item][item.id.to_s] && params[:line_item][item.id.to_s][:quantity]
        new_quantity = params[:line_item][item.id.to_s][:quantity];
        if new_quantity == "0"
          item.destroy
        else
          item.quantity = new_quantity
          item.save!
        end
      end
    end
    
    @cart.update_caches!
    if params[:commit] =~ /checkout/i
      redirect_to "/cart/checkout" 
    else     
      flash[:cart] = "Cart Updated" 
      respond_to do |wants|
        wants.html { redirect_to :action => :index }
        wants.js
      end
    end
  end
  
  def destroy
    item = @cart.line_items.find(params[:id])
    flash_msg = "#{ActionView::Helpers::TextHelper.pluralize item.quantity, item.product.name} <span class='description'>#{item.product.configuration}</span> #{item.quantity > 1 ? "have" : "has"} been removed from the cart."
    
    @cart.remove(params[:id])
    flash[:cart] = flash_msg
    respond_to do |wants|
      wants.html { redirect_to :action => :index }
      wants.js
    end
  end
  
private
  include Span::Blue::Routing


end