class PageTypes::Cart < Page
  
  configure_blue_page do |page| 
    page.type_name = "Cart"
  end
  
  class << self
    
    def instance
      @cart_page ||= self.working.find(:first) || self.create({:title => "Cart"})
    end

    def url
      @@url ||= self.instance.url
    end
    
  end
  
  def template
    @template ||= TemplateFile.find('/../cart/index.html.erb')
  end
  
  def slug
    "cart"
  end
  
  def generate_unique_slug!
     return self[:slug] = "cart"
  end
  
end