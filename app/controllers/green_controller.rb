class GreenController < ApplicationController
  unloadable
  
  helper Span::Helper
  helper_method :current_engine
  
  private
    def current_engine
      :green
    end
    
  include Span::Green::Initializers
end