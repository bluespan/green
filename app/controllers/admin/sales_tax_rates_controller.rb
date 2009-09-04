class Admin::SalesTaxRatesController < Admin::GreenAdminController
  layout "admin"
  before_filter :find_model
  unloadable

 
  def update
    respond_to do |wants|
      params[:sales_tax_rate].each do |state, rate|
        SalesTaxRate[state] = rate
      end
      
      flash.now[:notice] = "<em>Sales Tax Rates</em> were successfully <em>updated.</em>"
      wants.html { redirect_to :action => :show }
      wants.js do 
        responds_to_parent do
          render :action => :update
        end
      end
    
    end
  end

  private
  
  def find_model
    @sales_tax_rates = SalesTaxRate.all(:order => :state)
  end
end
