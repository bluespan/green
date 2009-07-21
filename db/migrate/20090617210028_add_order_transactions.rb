class AddOrderTransactions < ActiveRecord::Migration 
  def self.up 
    create_table :order_transactions do |t| 
      t.integer :order_id 
      t.integer :amount 
      t.boolean :success 
      t.string  :reference 
      t.string  :message 
      t.string  :action 
      t.text    :params 
      t.boolean :test 
      t.timestamps 
    end 
    
    add_column :orders, :state, :string, :default => 'pending'
    add_index :order_transactions, :order_id
  end 
  def self.down 
    remove_column :orders, :state
    remove_index :order_transactions, :order_id
    drop_table :order_transactions 
  end 
end 
