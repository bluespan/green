class LineItemAttachment < ActiveRecord::Base
  unloadable
  
  belongs_to :line_item
  belongs_to :option
    
  has_attached_file :file, :styles => { :thumbnail => "64x64#" }, 
                           :path => ":rails_root/public/assets/:class/:attachment/:id/:style_:basename.:extension",
                           :url => "/assets/:class/:attachment/:id/:style_:basename.:extension"
  

end