class AddAddress < ActiveRecord::Migration
  def self.up
    create_table :addresses do |t|
      t.string  :firstname
      t.string  :lastname
      
      t.string  :street
      t.string  :street2
      t.string  :city
      t.string  :state
      t.string  :postal_code
      t.string  :country
      
      t.string  :phone
    end
  end

  def self.down
    drop_table :addresses
  end
end
