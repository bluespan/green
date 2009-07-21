class Product < ActiveRecord::Base

  acts_as_money :base_price, :currency => "USD", :amount => :base_price_in_cents
  acts_as_money :base_shipping, :currency => "USD", :amount => :base_shipping_in_cents
  
  acts_as_paranoid
  
  has_attached_file :photo, :styles => { :catalog => "120x120#", :cart => "64x64#" }, 
                            :default_style => :catalog, :default_url => "/plugin_assets/green/images/product_image_not_available_:style.gif",
                            :path => ":rails_root/public/assets/product/:attachment/:id/:style_:basename.:extension",
                            :url => "/assets/product/:attachment/:id/:style_:basename.:extension"
  
  has_many :options, :order => :position do
    def of_attribute(attribute)
      find :all, :conditions => ["attribute = ?", attribute.to_s]
    end
    
    def configuration(option_ids)
      configuration = configured_with(option_ids).sort! {|x, y| proxy_owner.product_attribute_sort(x, y) } || []
     
      def configuration.[] (key)
        selection = self.select { |o| o.id.to_s == key.to_s or o.attribute.to_s == key.to_s }
        return selection.first if selection.size > 0 and selection.first.id.to_s == key.to_s
        selection
      end
      
      def configuration.to_s
        self.collect{ |o| "#{o.attribute.gsub("_", " ").capitalize}: #{o.name}"}.join(", ")
      end
      
      def configuration.to_url
        return "" if size == 0
        "?#{self.collect{ |o| "configuration[#{o.attribute.downcase}][]=#{o.id}"}.join("&")}"
      end
      
      return configuration
    end
  end
       
  has_many :categories, :dependent => :destroy
  
  before_validation :generate_unique_slug!
    
  attr_accessor :current_configuration  
  class_inheritable_accessor :types
    
  def starting_price
    base_price
  end  
    
  def css_class
    (self.class.to_s.split("::")[1] || "product").underscore
  end

  def generate_unique_slug!
    return self[:slug] unless self[:slug].blank?
    
    # StringExtensions method
    self[:slug] = self[:name].to_url 
    
    # Make sure slug is unique-like
    unless ( product = Product.last({:conditions => ["slug like ?", self[:slug]+"%"], :order => "slug"}) ).nil?
      incrementer = product.slug.match(/(-\d+)$/).to_a[1] || "-1"
      self[:slug] += incrementer.next
    end
  end
  
  def url
    @url ||= {}
    @url[current_configuration] ||= "#{categories.first.ancestors.collect{|c| "/#{c.slug}"}}/#{slug}" + current_configuration.to_url
  end
  
  def configuration(option_ids = nil)
    return self.current_configuration if option_ids.nil? && configured?
    @configuration ||= {}
    @configuration[option_ids] ||= options.configuration(option_ids)
  end
  
  def configuration_price
    base_price + @current_configuration.sum(0, &:price)
  end
  
  
  def configuration_photo
    @configuration_photo ||=  @current_configuration.collect { |item| item.photo if item.photo?}.compact.first || photo
  end
  
  
  def configure!(option_ids)
    raise RequiresConfiguration if option_ids.blank? && requires_configuration?
    self.current_configuration = configuration(option_ids)
  end
  
  def set_option_attachments(attachments)
    attachments.each do |attachment|
      unless configuration[attachment.option_id].nil?
        configuration[attachment.option_id].attachments << attachment
      end
    end
  end
  
  def configured?
    not self.current_configuration.nil?
  end

  def requires_configuration?
    false
  end


    

  
  class RequiresConfiguration < Exception
  end
  
end

