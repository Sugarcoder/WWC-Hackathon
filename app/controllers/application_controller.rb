class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?

  rescue_from CanCan::AccessDenied do |exception|
    @error_message = exception.message
    render :file => "#{Rails.root}/public/403.html", :status => 403, :layout => false
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up){ |u| u.permit(:username, :email, :password, :password_confirmation, :firstname, :lastname, :organization, :telephone, :is_under_eighteen) }
    devise_parameter_sanitizer.for(:account_update){ |u| u.permit(:username, :email, :password, :password_confirmation, :firstname, :lastname, :organization, :telephone, :current_password, :role, :avatar, :is_under_eighteen) }
  end
end
