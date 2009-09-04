# Green

require 'green/extensions/routes'

module Span

  module Green #:nodoc:
    
    mattr_accessor :gateway_parameters
    Span::included_engines << "green"
    Span::admin_stylesheets[:green] = ["green"]
    
    module Routing
      
      protected
      
      def Routing.included(mod)
         Span::Blue::Routing.map_page_type_route PageTypes::Catalog, :route_catalog
      end
      
      def route_catalog
        categories = @slugs[@slug_index + 1, @slugs.size - @slug_index + 1]
        @page.body_id = "catalog"
        return load_category(categories, @page.category_id)
      end
      
      def load_category(categories, parent_category_id = nil)
        if categories.size > 0
          if category_tree = Category.find_by_url_path(categories, parent_category_id)
            @category = category_tree.last

            if categories.size > category_tree.size
              return load_product
            else
               @categories = @category.children({ :include => :product })
            end
          else
            return false
          end
        else
          if @page.category_id?
            @category = @page.category
            @categories = @category.children
          else
            @categories = Category.roots
          end
        end
        
        {:template => 'catalog/show'}
      end
      
      def load_product
        if params[:line_item] and not ( @line_item = @cart.line_items.find_by_id(params[:line_item])).nil?
          @attachments = @line_item.line_item_attachments
        else
          @attachments = {}
        end
        @configuration = params[:configuration] || {}
        @page = PageTypes::Catalog.working.find(:first)
        @product = Product.find_by_slug(params[:slug])
        @page.body_id = "product"
        {:template => 'catalog/product'}
      end
    end
    
    module Initializers
      def initialize_cart
        unless session[:cart_id] and @cart = Cart.find_by_id(session[:cart_id])
          @cart = Cart.create
          session[:cart_id] = @cart.id
        end
      end
      
      def unintialize_cart
        session[:cart_id] = nil
      end
    end
    
    module ProductMethods #:nodoc:

      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def configure_green_product
          cattr_accessor :product_attribute_configs, :type_name
          
          self.product_attribute_configs ||= []
          
          include Span::Green::ProductMethods::InstanceMethods
          extend  Span::Green::ProductMethods::SingletonMethods
          
          yield self
        end
      end

      module SingletonMethods
        # Add class methods here
        def add_attribute(attribute = {})
          
          if attribute.has_key?(:name)
            self.product_attribute_configs << attribute
          else
            self.product_attribute_configs << attribute.merge({:name => attribute.to_a[0][0], :type => attribute.to_a[0][1]})
          end
          
        end
      end

      module InstanceMethods
        # Add instance methods here
        def product_attributes
          @product_attributes ||= self.product_attribute_configs.collect { |attribute| attribute.fetch(:type).new(self.id, attribute) }
        end
        
        def product_attributes_with_options
          @product_attributes_with_options ||= product_attributes.delete_if { |attribute| options.of_attribute(attribute.name).empty? }
        end
        
        def product_attribute(name)
          product_attributes.select{ |attribute| attribute.name.to_sym == name.to_sym}.first
        end
        
        def product_attribute_sort(x, y)
          product_attributes.index(product_attribute(x.attribute)) <=> product_attributes.index(product_attribute(y.attribute))
        end
      end
    end
  end
end
