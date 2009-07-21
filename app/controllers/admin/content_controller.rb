class Admin::ContentController < Admin::GreenAdminController
  layout "admin"
  unloadable

  helper 'admin/content'

  def update
    params[:content].each do |id, content_params|
      content = Content.find(id)
      content.update_attributes(content_params)
    end
    
    redirect_to :action => :index
  end
  
end
