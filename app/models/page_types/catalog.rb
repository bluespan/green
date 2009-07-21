class PageTypes::Catalog < Page
  
  belongs_to :category
  
  configure_blue_page do |page| 
    page.type_name = "Catalog"
  end
  
  def self.instance
    @@catalog_page ||= self.working.find(:first) || self.create({:title => "Catalog"})
  end
  
  def self.url
    @@url ||= self.instance.url
  end
  
  def template
    @template ||= TemplateFile.find('../../catalog/show.html.erb')
  end
  
  
end