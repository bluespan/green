class Admin::CategoriesController < Admin::GreenAdminController
  unloadable
  
  #before_filter :verify_editor  
  layout false
  
  def new
    @category = Category.new
    @ref_id, @position = params[:ref_id], params[:position]
    respond_to do |wants|
      wants.html
    end
  end
  
  def create
    @category = Category.new(params[:category])
    @ref_id, @position = params[:ref_id], params[:position]
    
    respond_to do |wants|
      if @category.save
        unless @ref_id.blank? || @position.blank?
          @reference_category = Category.find(@ref_id)

          @moved = case @position
            when "before" : @category.move_to_left_of  @reference_category
            when "after"  : @category.move_to_right_of @reference_category
            when "inside" : @category.move_to_child_of @reference_category
          end
        end
        
        flash.now[:notice] = "Category <em>#{@category.name}</em> was successfully <em>created.</em>"
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
            render :template => "admin/error", :locals => {:object => @category}
          end
        end
      end
    end
  end
  
  
  def edit
    @category = Category.find(params[:id])
    respond_to do |wants|
      wants.html
    end
  end
  
  def update
    @category = Category.find(params[:id])

    respond_to do |wants|
      if @category.update_attributes(params[:category])
        flash.now[:notice] = "#{@category.class.to_s.underscore.titleize} <em>#{@category.name}</em> was successfully <em>updated.</em>"
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
            render :action => :update
          end
        end
        
      end
    end
  end  
  
  def move
    @reference_category = Category.find(params[:reference_id])
    
    if (params[:type] == "product")
      @product = Product.find(params[:id])
      @category = Category.create({:product_id => params[:id]})
    else
      @category = Category.find(params[:id])
      flash.now[:notice] = "Category <em>#{@category.name}</em> was successfully <em>moved.</em>"
    end
    
    @moved = case params[:where]
      when "left"   : @category.move_to_left_of  @reference_category; @position = "before"
      when "right"  : @category.move_to_right_of @reference_category; @position = "after"
      when "child"  : @category.move_to_child_of @reference_category; @position = "inside"
    end
    
    if (params[:type] == "product")
      if @category.root?
        added_to = "<em>to</em> the <em>catalog</em>."
      else
        added_to = "<em>to</em> category <em>#{@category.parent.name}.</em>"
      end
      flash.now[:notice] = "#{@category.product.type_name} <em>#{@category.product.name}</em> was successfully <em>added</em> #{added_to}"
    end
    
    if @moved
      respond_to do |wants|
        wants.js
      end
    end

  end
  
  def destroy  
    @category = Category.find(params[:id])
    @old_category_id = @category.id  
    @old_category_name = @category.name
    
    if @category.product_id?
      @product_name = @category.product.name 
      if @category.root?
        from ="<em>from</em> the <em>catalog.</em>" 
      else
        from = "<em>from</em> the category <em>#{@category.parent.name}.</em>" 
      end
    end
    
    respond_to do |wants|
      if @category.destroy
        if @product_name
          flash.now[:notice] = "Product <em>#{@product_name}</em> was successfully <em>removed</em> #{from}"
        else
          flash.now[:notice] = "Category <em>#{@old_category_name}</em> was successfully <em>removed from the catalog.</em>"
        end
        wants.html { redirect_to :action => "index" }
        wants.js
      end
    end
  end
  
  private
  
  def verify_editor
    head :forbidden unless current_admin_user.has_role?(:editor)
  end
 
end
