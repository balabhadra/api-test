# Overriding devise's Session Controller
module Api
  module V1
    class SessionsController < ::Devise::SessionsController

      respond_to :json 
      
      # Skip CSRF check for json requests.
      skip_before_filter :verify_authenticity_token, if: :json_request?
      
      # Authenticate via token+email. 
      # https://github.com/gonzalo-bulnes/simple_token_authentication
      acts_as_token_authentication_handler_for User, only: [:destroy], fallback_to_devise: false

      
      # Devise filter for logout. Not needed for api access
      skip_filter :verify_signed_out_user, only: :destroy   

      # Log user in.
      # POST api/v1/users/sign_in.json
      def create
        self.resource = warden.authenticate!     
        render json: {success: true, user: resource}
      end

      # User logs out. Check if user is a valid user. If valid, reset api authentication token
      # POST api/v1/users/sign_out.json
      def destroy
        if user_signed_in?
          @user = current_user
          @user.authentication_token = nil
          @user.save
        else
          render json: { message: 'Failed to log out. You must be logged in.'}, status: 401
        end
      end

      private

      def json_request?
        request.format.json?
      end

    end
  end
end
