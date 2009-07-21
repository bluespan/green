class AddAttributeUpload < ActiveRecord::Migration
  def self.up
    add_column :options, :allow_file_upload, :boolean
    add_column :options, :allow_text_input, :boolean

    add_column :orders, :authorization_id, :string
  end

  def self.down
    remove_column :orders, :authorization_id
    
    remove_column :options, :allow_text_input
    remove_column :options, :allow_file_upload
  end
end
