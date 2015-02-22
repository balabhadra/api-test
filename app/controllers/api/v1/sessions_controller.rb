# Overriding devise's Session Controller
module Api
  module V1
    class SessionsController < ::Devise::SessionsController

      # Authenticate via token+email. 
      # https://github.com/gonzalo-bulnes/simple_token_authentication
      # User does not need to authenticate create.
      # Setting fallback_to_devise to false will not use devise for authentication. This is for security reasons
      acts_as_token_authentication_handler_for User, only: [:destroy], fallback_to_devise: false
      
      # Handle invalid users. This is needed since fallback_to_devise is set to false
      before_filter :validate_user, only: [:destroy]  
      
      # Skip unnecessary filters
      skip_before_filter :verify_authenticity_token, if: :json_request?
      skip_filter :verify_signed_out_user, only: :destroy 

      # API protection from CSRF
      protect_from_forgery with: :null_session, except: [:create]
      
      # Log user in.
      # POST api/v1/users/sign_in.json
      def create
        self.resource = warden.authenticate!     
        render json: {success: true, user: resource}
      end

      # User logs out. Check if user is a valid user. If valid, reset api authentication token
      # POST api/v1/users/sign_out.json
      def destroy
        current_user.authentication_token = nil
        current_user.save
        render json: {success: true, message: "Logged out successfully"}
      end

      protected

      def json_request?
        request.format.json?
      end

      def validate_user
        user_signed_in? || throw(:warden, scope: :user)
      end

    end
  end
end
