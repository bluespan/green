class AddLineItemAttachments < ActiveRecord::Migration
  def self.up
    create_table :line_item_attachments, :force => true do |t|
      t.integer :line_item_id
      t.integer :option_id
      
      t.string    :file_file_name
      t.string    :file_content_type
      t.integer   :file_file_size
      t.datetime  :file_updated_at
      
      t.text :text_input
      
      t.timestamps
    end
    
    add_index :line_item_attachments, [:line_item_id, :option_id]
  end

  def self.down
    remove_index  :line_item_attachments, [:line_item_id, :option_id]
    drop_table    :line_item_attachments
  end
end
