class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  # Authenticate users before any action
  before_action :authenticate_user!

  #Sanitize device parameters
  before_action :configure_permitted_parameters, if: :devise_controller?
  
  # Redirect after sign in to products index
  def after_sign_in_path_for(resource)
    products_path
  end
  
  # Redirect after sign up to products index
  def after_sign_up_path_for(resource)
    products_path
  end
  
  protected
  
  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:username, :email, :password, :password_confirmation, :remember_me) }
    devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:login, :username, :email, :password, :remember_me) }
    devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:username, :email, :password, :password_confirmation, :current_password) }
  end
end
