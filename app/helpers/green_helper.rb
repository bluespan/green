module GreenHelper
  def nested_set_list_for(options = {})
    options = {:partial => nil, :collection => [], :class => "", :id => ""}.merge(options)
    returning "" do |html|
      html << "<ul #{"id=\""+options[:id]+"\"" unless options[:id].blank?} #{"class=\""+options[:class]+"\"" unless options[:class].blank?}>" 
      
      unless options[:collection].empty?
        options[:collection].each do |object|
          if options[:partial]
            html << "<li>"
            html << render(:partial => options[:partial], :locals => {(options[:partial].to_sym || :object) => object})
          else
            html << object
          end
          html << nested_set_list_for({:partial => options[:partial], :collection => object.children}) unless object.children.empty?
          html << "</li>"
        end
      end  
      html << "</ul>"
    end
  end
end