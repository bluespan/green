class Admin::GreenAdminController < GreenController
  layout "admin"
  before_filter :require_admin_session
  
  private
  
  def require_admin_session
    redirect_to new_admin_session_url if current_admin_user.nil?
  end
  
end