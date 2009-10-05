class CreateProductContent < ActiveRecord::Migration
  def self.up
    create_table :product_content do |t|
      t.integer :product_id
      t.string  :type
      t.string  :title
      t.text    :content

      t.boolean   :published, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :product_content
  end
end
