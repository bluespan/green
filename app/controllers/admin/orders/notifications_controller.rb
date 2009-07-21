class Admin::Orders::NotificationsController < Admin::GreenAdminController
  layout false
  before_filter :find_model
  unloadable

  def new
    @notification = Comment.new
  end
  
  def create
    @order.comments << @notification = Comment.create( params[:comment] )
    @notification.notify_with_email({ :recipients => @order.email })
    flash.now[:notice] = "<em>Notification</em> was successfully <em>created</em> and <em>sent.</em>"
    
  end
  
  private
  
  def find_model
    @order = Order.find(params[:order_id]) if params[:order_id]
  end
end
