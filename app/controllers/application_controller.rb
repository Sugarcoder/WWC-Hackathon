class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?
  skip_before_action :verify_authenticity_token, if: :json_request?

  rescue_from CanCan::AccessDenied do |exception|
    @error_message = exception.message
    render file: "#{Rails.root}/public/403.html", status: 403, layout: 'public_page_layout'
  end

  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up){ |u| u.permit(:username, :email, :password, :password_confirmation, :firstname, :lastname, :organization, :telephone, :is_under_eighteen) }
    devise_parameter_sanitizer.for(:account_update){ |u| u.permit(:username, :email, :password, :password_confirmation, :firstname, :lastname, :organization, :telephone, :current_password, :role, :avatar, :is_under_eighteen) }
  end

  def json_request?
    request.format.json?
  end

  def record_not_found
    render file: "#{Rails.root}/public/404.html", status: 404, layout: 'public_page_layout'
  end
end
