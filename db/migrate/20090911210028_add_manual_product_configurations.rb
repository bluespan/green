class AddManualProductConfigurations < ActiveRecord::Migration
  def self.up
    create_table :manual_product_configurations, :force => true do |t|
      t.integer :product_id
      t.string  :option_ids
      
      t.boolean :price_manual, :default => false
      t.integer :price_in_cents
      
      t.boolean :shipping_manual, :default => false
      t.integer :shipping_in_cents
      
      t.boolean :not_available, :default => false
      
      t.timestamps
    end
  end

  def self.down
    drop_table :product_configurations
  end
end
