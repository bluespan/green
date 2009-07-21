class CatalogController < GreenController
  unloadable
  
  helper :pages
  before_filter :initialize_cart
  
  def show
    @page = PageTypes::Catalog.working.find(:first)
    if params[:slug]
      @category = Category.find_by_slug(params[:slug])
      
      if @category
        @categories = @category.children({ :include => :product })
      else
        return product
      end
      
    else
      @categories = Category.roots
    end
    route
  end
  
  def product
    if params[:line_item] and not ( @line_item = @cart.line_item.find(params[:line_item]).nil? )
      @attachments = @line_item.line_item_attachments
    else
      @attachments = {}
    end
    @configuration = params[:configuration] || {}
    @page = PageTypes::Catalog.working.find(:first)
    @product = Product.find_by_slug(params[:slug])
    route
    render :action => :product
  end

private
  include Span::Blue::Routing

end