class AddOrder < ActiveRecord::Migration
  def self.up
   create_table :orders do |t|
      t.string  :order_number
      t.integer :quantity, :default => 0
      t.integer :subtotal_in_cents, :default => 0
      t.integer :tax_in_cents, :default => 0
      t.integer :shipping_in_cents, :default => 0
      t.integer :total_in_cents, :default => 0
      t.integer :billing_id
      t.integer :shipping_id
      
      t.string  :email
      
      t.string  :credit_card_type
      t.string  :credit_card_number
      t.integer :credit_card_month
      t.integer :credit_card_year
      
      t.timestamps
    end
    
    add_column :line_items, :order_id, :integer
    add_index :line_items, :order_id
    add_index :orders, :order_number
  end

  def self.down
    remove_index :orders, :order_number
    remove_index :line_items, :order_id
    remove_column :line_items, :order_id
    drop_table :orders
  end
end
