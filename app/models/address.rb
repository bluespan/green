class Address < ActiveRecord::Base
  unloadable

  validates_presence_of :firstname, :lastname, :street, :city, :state, :postal_code

end