class Admin::ConfigurationsController < Admin::GreenAdminController
  layout false
  before_filter :find_product
  unloadable

  def index
    
  end
  
  def update
    @product.manual_product_configurations.delete_all
    
    params[:configuration].each do |option_ids, values|
      if (values.keys & ["price_manual", "shipping_manual", "not_available"]).size > 0
        @product.manual_product_configurations.create({:option_ids => option_ids}.merge(values))
      end
    end
    
    flash.now[:notice] = "#{@product.name}'s <em>configurations</em> were successfully <em>updated.</em>"
    
    responds_to_parent do
      render :action => :update
    end
  end

  private
  
  
  def find_product
    @product = Product.find(params[:product_id])
  end
end
