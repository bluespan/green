class AddShippingToCart < ActiveRecord::Migration
  def self.up
    add_column :carts, :shipping_in_cents, :integer, :default => 0
    add_column :line_items, :shipping_in_cents, :integer, :default => 0
  end

  def self.down
    remove_column :line_items, :shipping_in_cents
    remove_column :carts, :shipping_in_cents
  end
end
