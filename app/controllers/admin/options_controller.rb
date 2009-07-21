class Admin::OptionsController < Admin::GreenAdminController
  layout false
  unloadable

  before_filter :load_product_and_attribute

  def add
    @option = Option.new(params[:new_option])
    render :partial => "option", :locals => {:option => @option}
  end
  
  def update
    params[:option].each do |key, option|
      option.merge!({:position => params[:position].index(key).to_i + 1})
      if key =~ /new/
        Option.create( option.merge({ :product_id => @product.id, :attribute => @attribute.name.to_s }) )
      else
        Option.find_with_deleted(key).update_attributes(option)
      end
    end
    flash.now[:notice] = "#{@product.name}'s <em>#{@attribute.name}</em> attriute was successfully <em>updated.</em>"
  
    responds_to_parent do
      render :action => :update
    end
  end

  private
  
  def load_product_and_attribute
    @product = Product.find_with_deleted params[:product_id]
    @attribute = @product.product_attribute params[:attribute_name]
  end

end
