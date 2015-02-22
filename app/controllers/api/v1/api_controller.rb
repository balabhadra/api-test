# Base class for all api controllers except for session and registration which are subclassed from devise.
# This class is derived from ActionController::Base.
module Api
  module V1
    class ApiController < ::ActionController::Base

      protect_from_forgery with: :null_session
      
      respond_to :json
      
      # Define which model will act as token authenticatable. Used to authenticate via token
      # https://github.com/gonzalo-bulnes/simple_token_authentication
      acts_as_token_authentication_handler_for User, fallback_to_devise: false
      before_filter :validate_user
           
      # Handle errors. Always place this at the top, otherwise it will swallow all exceptions 
      unless Rails.application.config.consider_all_requests_local
        rescue_from Exception, :with => :internal_server_error
      end

      rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
      rescue_from ActionController::UnknownFormat, with: :unknown_format

      protected
      
      def validate_user
        user_signed_in? || throw(:warden, scope: :user)
      end
      
      def record_not_found(error)
        logger.error error.message
        logger.error error.backtrace.join("\r\n")
        render json: {error: error.message}, status: :not_found
      end
      
      def unknown_format(error)
        logger.error error.message
        logger.error error.backtrace.join("\r\n")
        render json: {error: "Unknown Format"}, status: :not_acceptable
      end
      
      def internal_server_error(error)
        logger.error error.message
        logger.error error.backtrace.join("\r\n")
        render json: {error: "Internal Server error"}, status: :internal_server_error
      end

    end
  end
end