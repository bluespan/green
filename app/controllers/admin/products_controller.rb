class Admin::ProductsController < Admin::GreenAdminController
  layout "admin", :only => :index
  before_filter :find_model, :except => [:index, :publish_all]
  unloadable

  def new
     @ref_id, @position = params[:ref_id], params[:position]
    respond_to do |wants|
      wants.html
    end
  end
  
  def edit
    respond_to do |wants|
      wants.html
    end
  end
 
  def create
    @ref_id, @position = params[:ref_id], params[:position]
    respond_to do |wants|
      if @product.save 

        flash.now[:notice] = "#{@product.type_name} <em>#{@product.name}</em> was successfully <em>created.</em>"
        wants.html { redirect_to :action => "index "}
        wants.js do 
          responds_to_parent do
            render :action => :create
          end
        end
      else
        wants.html { render :action => "new" }
        wants.js do 
          responds_to_parent do
            render :template => "admin/error", :locals => {:object => @product}
          end
        end
      end
    end
  end
  
  def update
    respond_to do |wants|
      if @product.update_attributes(params[:product])
    
        flash.now[:notice] = "#{@product.type_name} <em>#{@product.name}</em> was successfully <em>updated.</em>"
        wants.html { redirect_to :action => "index "}
        wants.js do 
          responds_to_parent do
            render :action => :update
          end
        end
      else
        wants.html { render :action => "edit" }
        wants.js do 
          responds_to_parent do
            render :template => "admin/error", :locals => {:object => @product}
          end
        end
      end
    end
  end
  
  def destroy  
     respond_to do |wants|
        if @product.destroy

          flash.now[:notice] = "#{@product.type_name} <em>#{@product.name}</em> was successfully <em>deleted.</em>"
          wants.html { redirect_to :action => "index "}
          wants.js
        else
          wants.html { render :action => "edit" }
          wants.js { render :template => "admin/error", :locals => {:object => @product} }
        end
      end
  end
  
  
  private
  
  
  def find_model
    if params[:product] && params[:product][:type]
      model_type = params[:product][:type]
      type = model_type.split("::")[1]
      params[:product].delete(:type)
      model_class = type ? Module.const_get("ProductType").const_get(type) : Product
    else
      model_class = ProductType::Simple
    end
    
    if params[:id]
      @product = Product.find(params[:id])
      
      if params[:product]
        @product.send(:attributes=, params[:product], false)
        @product.type = model_type
      end
    else
      @product = model_class.new(params[:product])
    end
  end
end
