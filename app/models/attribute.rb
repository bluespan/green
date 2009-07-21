class Attribute
  unloadable
  
  def initialize(product_id, config = {})
    @config = config
    @product_id = product_id
  end
  
  def self.type_name
    "Attribute"
  end
  
  def display_name
    name.to_s.gsub("_", " ")
  end
  
  def css_class
    (self.type.to_s.split("::")[1] || "attribute").underscore
  end
  
  def name
    @config[:name]
  end
  
  def update_config(config)
    @config = @config.merge(config)
  end
  
  def allow_file_upload?
    @config.has_key?(:allow_file_upload) and @config[:allow_file_upload]
  end
 
  def allow_text_input?
    @config.has_key?(:allow_text_input) and @config[:allow_text_input]
  end
end