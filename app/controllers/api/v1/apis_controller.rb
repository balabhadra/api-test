module Api
  module V1
    class ApisController < ::ActionController::Base
      # define which model will act as token authenticatable
      acts_as_token_authentication_handler_for User

      before_action :configure_permitted_parameters, if: :devise_controller?

      protected

      def configure_permitted_parameters
        devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:username, :email, :password, :password_confirmation, :remember_me) }
        devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:login, :username, :email, :password, :remember_me) }
        devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:username, :email, :password, :password_confirmation, :current_password) }
      end

    end
  end
end