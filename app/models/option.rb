class Option < ActiveRecord::Base
  unloadable
  acts_as_money :price, :currency => "USD", :amount => :price_in_cents
  acts_as_money :shipping, :currency => "USD", :amount => :shipping_in_cents
  
  attr_internal :discontinued
  
  acts_as_paranoid
  
  has_attached_file :photo, :styles => { :catalog => "120x120#", :cart => "64x64#" }, 
                            :default_style => :catalog, 
                            :path => ":rails_root/public/assets/:class/:attachment/:id/:style_:basename.:extension",
                            :url => "/assets/:class/:attachment/:id/:style_:basename.:extension"
  
  belongs_to :product
  
  named_scope :configured_with, lambda { |option_ids| { :conditions => { :id => option_ids.split(/[^0-9]+/) } } }

  before_save :update_discontinued_status
  
  attr_accessor :attachments
  
  def update_discontinued_status
    if discontinued != nil and deleted_at.nil?
      return false if id.nil?
      self.deleted_at = Time.now
      ActiveRecord::Base.logger.info "discontinued #{attributes}"
    end    
    
    if discontinued == nil && deleted_at.nil? == false
      self.deleted_at = nil
    end      
  end
  
  def discontinued?
    discontinued != nil || deleted_at.nil? != false
  end
  
  def attachments
    @attachments ||= []
  end
end