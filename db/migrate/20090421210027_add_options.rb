class AddOptions < ActiveRecord::Migration
  def self.up
    create_table :options, :force => true do |t|
      t.string    :name
      t.text      :description
      
      t.integer   :product_id
      t.string    :attribute
      t.integer   :position
      
      t.integer   :price_in_cents
      t.integer   :shipping_in_cents
      t.float     :weight
      t.string    :part_number
      
      t.string    :photo_file_name
      t.string    :photo_content_type
      t.integer   :photo_file_size
      t.datetime  :photo_updated_at
      
      t.timestamps
    end
    
    add_index :options, [:product_id, :attribute]
  end

  def self.down
    remove_index :options, [:product_id, :attribute]
    drop_table :options
  end
end
