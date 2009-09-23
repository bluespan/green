class Product < ActiveRecord::Base

  acts_as_money :base_price, :currency => "USD", :amount => :base_price_in_cents
  acts_as_money :base_shipping, :currency => "USD", :amount => :base_shipping_in_cents
  
  acts_as_paranoid
  
  has_attached_file :photo, :styles => { :catalog => "120x120#", :cart => "64x64#" }, 
                            :default_style => :catalog, :default_url => "/images/green/product_image_not_available_:style.gif",
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
  
      
      return configuration
    end
  end
  
  has_many :manual_product_configurations do
    def [](option_ids)
      option_ids = option_ids.join(",") if option_ids.is_a?(Array)
      result = self.find_all{ |config| config.option_ids == option_ids}
      return result.first if result.size > 0
      nil
    end
  end
       
  has_many :categories, :dependent => :destroy
  
  before_validation :generate_unique_slug!
    
  attr_accessor :current_configuration, :ancestors
  class_inheritable_accessor :types
    
  def starting_price
    base_price ||= 0
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
    
    configuration_url = current_configuration.nil? ? "" : current_configuration.configuration_url 
    
    @url[current_configuration] ||= "#{ancestors.collect{|c| "/#{c.slug}"}}/#{slug}" + configuration_url
  end
  
  def configuration
    return self.current_configuration if configured?
    
    @configuration ||= {}
    @product = self
    
    def @configuration.product=(product)
      @product = product
    end
    
    @configuration.product = self
    
    def @configuration.[](option_ids = "")
      unless self.has_key?(option_ids)
        config = @product.instantiate_configuration(option_ids)
        config.options = @product.options.configuration(option_ids)
        self.store(option_ids, config)
      end
      self.fetch(option_ids)
    end
    
    @configuration
  end
  
  def configuration_price
    #(base_price || 0) + current_configuration.sum(0, &:price)
  end
  
  def ancestors
    @ancestors ||= categories.first.ancestors
  end

  
  def configuration_photo
    #@configuration_photo ||=  @current_configuration.collect { |item| item.photo if item.photo?}.compact.first || photo
  end
  
  
  def configure!(option_ids)
    raise RequiresConfiguration if option_ids.blank? && requires_configuration?
    self.current_configuration = configuration[option_ids]
  end
  
  def current_configuration
    @current_configuration
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

  def configurations   
    @configuration ||= {} 
    @configuration_keys ||= []
    configurations_r!(product_attribute_configs) if @configuration_keys.empty?

    @configuration_keys
  end

  def instantiate_configuration(option_ids)
    config = manual_product_configurations[option_ids] || ProductConfiguration.new
    config.product = self
    config
  end
  
  class RequiresConfiguration < Exception
  end

  private
  
  def configurations_r!(attributes, config = [])
    return if attributes.size == 0
    
    options.of_attribute(attributes.first[:name]).each do |option|
      if attributes.size == 1
        @configuration_keys << (key = (config + [option]).map(&:id))
        
        @configuration[key] = instantiate_configuration(key)
        @configuration[key].options = config + [option]
      else
        configurations_r!(attributes.slice(1, attributes.size - 1), config + [option])
      end
    end
    
  end
  

end

class ProductConfiguration < ManualProductConfiguration
  
  def options=(opts)
    @options = opts
    
    if opts.empty?
      self.price = product.base_price
      self.shipping = product.base_shipping
    else
      self.price = opts.sum(&:price) + product.base_price
      self.shipping = opts.sum(&:shipping) + product.base_shipping
    end
    
    self.option_ids = opts.map(&:id).join(",")
  end
  
end

