class AddCart < ActiveRecord::Migration
  def self.up
    create_table :carts do |t|
      t.integer :quantity, :default => 0
      t.integer :subtotal_in_cents, :default => 0
      t.string  :checkout_state
      t.integer :billing_id
      t.integer :shipping_id
    end
    
    create_table :line_items do |t|
      t.integer  :cart_id
      t.integer  :product_id
      t.string   :configuration
      t.integer  :quantity
      t.integer  :price_in_cents
      
      t.timestamps
    end
    
    add_index :line_items, :cart_id
  end

  def self.down
    remove_index :line_items, :cart_id
    drop_table :line_items
    drop_table :carts
  end
end
