class SalesTaxRate < ActiveRecord::Base
  
  class << self
    @@sales_tax_rates ||= {}
    
    def [](state)
      SalesTaxRate.find_by_state(state)
    end
    
    def []= (state, rate)
      SalesTaxRate.find_by_state(state).update_attributes({:rate => rate})
    end
    
    def all_states
      SalesTaxRate.find(:all).each do |sales_tax_rate|
        @@sales_tax_rates[sales_tax_rate.state] ||= sales_tax_rate
      end
    end
    
    def find_by_state(state)
      @@sales_tax_rates[state] ||= ( SalesTaxRate.find(:first, :conditions => {:state => state}) || SalesTaxRate.new({:state => state, :rate => 0.0}) )
    end
  end
  
end