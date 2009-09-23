class LineItem < ActiveRecord::Base
  unloadable
  
  belongs_to :cart
  belongs_to :product
  
  has_many :line_item_attachments, :dependent => :destroy do
    def [](option_id)
      self.select { |attachment| attachment.option_id.to_s == option_id.to_s }.first
    end
  end
  
  alias_method :orginal_product, :product
    
  acts_as_money :price, :currency => "USD", :amount => :price_in_cents
  
  def add_attachments(attachments)
    attachments.each do |option_id, attachment|
      if (line_item_attachment = line_item_attachments[option_id]).nil?
        if self[:configuration].include?(option_id)
          line_item_attachment = LineItemAttachment.create(attachment.update({:option_id => option_id, :line_item_id => id }))
        end
      else
        if self[:configuration].include?(option_id)  
          line_item_attachment.update_attributes(attachment)
        else
          line_item_attachment.destroy
        end
      end
    end
    
  end
  
  def subtotal
    price * quantity
  end
  
  def part_number
    product.configuration.part_number
  end
  
  def product
    @product ||= begin
      p = self.orginal_product
      p.configure!(self[:configuration])
      p.set_option_attachments(line_item_attachments)
      p
    end
  end
  
  def url
    @url ||= product.configuration.url
  end
  
end