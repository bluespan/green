if defined?(ActionController::Routing::RouteSet)
  class ActionController::Routing::RouteSet
    def load_routes_with_green!
      lib_path = File.dirname(__FILE__)
      
      app_routes = File.expand_path(File.join(lib_path, *%w[.. .. .. .. .. .. config routes.rb]))
      blue_routes = File.expand_path(File.join(lib_path, *%w[.. .. .. .. blue config blue_routes.rb]))
      green_routes = File.expand_path(File.join(lib_path, *%w[.. .. .. config green_routes.rb]))
      
      unless configuration_files.include?(green_routes)
        if !configuration_files.include?(app_routes)
          # App Routes Not Loaded
          configuration_files.unshift green_routes
          configuration_files.unshift app_routes
        elsif configuration_files.include?(blue_routes)
          # Blue Routes Loaded
          index = configuration_files.index(blue_routes)
          configuration_files.insert(index, green_routes)
        else
          # Blue Routes Not Loaded
          index = configuration_files.index(app_routes) + 1
          configuration_files.insert(index, green_routes)
        end
      end
      
      load_routes_without_green!
    end
 
    alias_method_chain :load_routes!, :green
  end
end