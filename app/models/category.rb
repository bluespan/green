class Category < ActiveRecord::Base
  unloadable
  
  has_attached_file :photo, :styles => { :catalog => "120x120#"}, 
                            :default_style => :catalog, :default_url => "/images/green/product_image_not_available_:style.gif",
                            :path => ":rails_root/public/assets/:class/:attachment/:id/:style_:basename.:extension",
                            :url => "/assets/:class/:attachment/:id/:style_:basename.:extension"
  
  acts_as_nested_set
  belongs_to :product

  named_scope :categories_only, :conditions => ["product_id is ?", nil]
  named_scope :with_parent_id, lambda { |parent_id|  { :conditions => ["parent_id = ?", parent_id] } }

  named_scope :with_products, :conditions => ["product_id is not ?", nil], :include => :product

  before_validation :generate_slug!
  
  def generate_slug!
    return self[:slug] unless self[:slug].blank? && !self[:name].blank?
    
    # StringExtensions method
    self[:slug] = self[:name].to_url 
  end
  

  def generate_unique_slug!
    generate_slug!
    
    # Make sure slug is unique-like
    unless ( category = Category.last({:conditions => ["slug like ?", self[:slug]+"%"], :order => "slug"}) ).nil?
      incrementer = category.slug.match(/(-\d+)$/).to_a[1] || "-1"
      self[:slug] += incrementer.next
    end
  end
  
  def url
    @url ||= self_and_ancestors.collect{|c| c.slug}.join("/")
  end
  
  def products
    @products ||= children.with_products.collect do |c|
      c.product.ancestors = self_and_ancestors
      c.product
    end
  end
  
  class << self
    
    def all_roots_and_descendants
      roots.map { |root| root.self_and_descendants}
    end
    
    def find_by_url_path(slugs, parent_category_id = nil)
      slugs = slugs.split("/").compact unless slugs.is_a? Array
      
      category_tree = []
      slugs.each do |slug|
        if category = Category.with_parent_id(parent_category_id).find_by_slug(slug)
          parent_category_id = category.id
          category_tree << category
        else
          return false unless slug == slugs.last
        end
      end
      
      category_tree
    end
    
  end

end