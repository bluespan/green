class GreenController < BlueController
  unloadable
  
  helper_method :current_engine
  
  private
    def current_engine
      :green
    end
    
  include Span::Green::Initializers
end