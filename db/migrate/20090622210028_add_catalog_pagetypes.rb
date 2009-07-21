class AddCatalogPagetypes < ActiveRecord::Migration 
  def self.up 
    add_column :pages, :category_id, :integer
  end 
  def self.down 
    remove_column :pages, :category_id

  end 
end 
