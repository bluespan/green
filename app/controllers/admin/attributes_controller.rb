class Admin::AttributesController < Admin::GreenAdminController
  layout false
  unloadable

  def show
    @product = Product.find params[:product_id]
    @attribute = @product.product_attribute params[:attribute_name]
  end
  

end
