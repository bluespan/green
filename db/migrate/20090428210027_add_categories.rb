class AddCategories < ActiveRecord::Migration
  def self.up
    create_table :categories do |t|
      t.string  :name
      t.integer :product_id
      t.boolean :live
      
      t.string  :slug
      t.text    :description
      
      t.integer :parent_id
      t.integer :lft
      t.integer :rgt
      
      t.string    :photo_file_name
      t.string    :photo_content_type
      t.integer   :photo_file_size
      t.datetime  :photo_updated_at
      
      t.timestamps
    end
    
    add_index :categories, :slug
  end

  def self.down
    remove_index :categories, :slug
    drop_table :categories
  end
end
