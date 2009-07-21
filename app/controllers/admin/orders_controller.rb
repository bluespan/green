class Admin::OrdersController < Admin::GreenAdminController
  layout "admin"
  before_filter :find_model
  unloadable

  private
  
  
  def find_model
    if params[:id]
      @order = Order.find(params[:id]) 
    else
      @orders = Order.paginate :page => params[:page], :order => 'id DESC', :per_page => 30, :include => :billing_address
    end
  end
end
