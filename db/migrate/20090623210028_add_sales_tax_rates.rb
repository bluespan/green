class AddSalesTaxRates < ActiveRecord::Migration 
  def self.up 
    create_table :sales_tax_rates, :force => true do |t|
      t.string :state
      t.float  :rate, :default => 0.0
      t.timestamps
    end
  end 
  def self.down 
    drop_table :sales_tax_rates
  end 
end 
