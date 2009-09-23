class PageTypes::Order < Page
  
  configure_blue_page do |page| 
    page.type_name = "Order"
  end
  
  def self.url
    @@url ||= "orders"
  end
  
  def template
    @template ||= TemplateFile.find('/../orders/show.html.erb')
  end
  
  def slug
    "orders"
  end
  
  def generate_unique_slug!
     return self[:slug] = "orders"
  end
  
end