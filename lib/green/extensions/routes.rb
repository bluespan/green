if defined?(ActionController::Routing::RouteSet)
  class ActionController::Routing::RouteSet
    def load_routes_with_green!
      lib_path = File.dirname(__FILE__)
      green_routes = File.join(lib_path, *%w[.. .. .. config green_routes.rb])
      
      unless configuration_files.include?(green_routes)
        # Make sure green loads before blue routes
        configuration_files.unshift green_routes
      end
      
      load_routes_without_green!

      
    end
 
    alias_method_chain :load_routes!, :green
  end
end