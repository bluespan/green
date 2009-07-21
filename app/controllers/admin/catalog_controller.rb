class Admin::CatalogController < Admin::GreenAdminController
  unloadable
  
  def show
    @products = Product.find(:all, :order => :name)
    @catagories = Product.find(:all, :order => :name)
  end
  
end