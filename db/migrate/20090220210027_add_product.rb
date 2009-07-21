class AddProduct < ActiveRecord::Migration
  def self.up
    create_table :products, :force => true do |t|
      t.string  :name
      t.string  :type
      t.string  :slug
      t.text    :description
      
      t.integer :base_price_in_cents
      t.integer :base_shipping_in_cents
      t.float   :base_weight
      t.string  :base_part_number
      
      t.string    :photo_file_name
      t.string    :photo_content_type
      t.integer   :photo_file_size
      t.datetime  :photo_updated_at
      
      t.timestamps
    end
  end

  def self.down
    drop_table :products
  end
end
