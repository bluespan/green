class AddDeletedAt < ActiveRecord::Migration
  def self.up
    add_column :products, :deleted_at, :datetime
    add_column :options, :deleted_at, :datetime
  end

  def self.down
    remove_column :options, :deleted_at
    remove_column :products, :deleted_at
  end
end
