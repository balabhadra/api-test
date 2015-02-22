module Api
  module V1
    class RegistrationsController < ::Devise::RegistrationsController
      
      # Authenticate via token+email. 
      # https://github.com/gonzalo-bulnes/simple_token_authentication
      # User does not need to authenticate create.
      # Setting fallback_to_devise to false will not use devise for authentication. This is for security reasons     
      acts_as_token_authentication_handler_for User, only: [:update, :destroy], fallback_to_devise: false
      
      # Handle invalid users. This is needed since fallback_to_devise is set to false
      before_filter :validate_user, only: [:update, :destroy]
      
      #Skip unrequired filters for api
      skip_before_filter :verify_authenticity_token, if: :json_request?
      skip_before_filter :authenticate_scope!, :only => [:update, :destroy]

      # User sign up
      # POST /api/v1/users.json
      def create
        build_resource(permitted_params)
        resource.save
        if resource.persisted?
          render json: {success: true, user: resource}
        else 
          clean_up_passwords resource
          render json: {success:false, errors: resource.errors}, :status => :unprocessable_entity
        end
      end

      # User sign up
      # PATCH /api/v1/users.json
      def update
        # Get a copy of current user
        self.resource = resource_class.to_adapter.get!(send(:"current_user").to_key)
        resource_updated = update_resource(resource, update_params)
        if resource_updated
          render json: {success: true, user: resource}
        else
          clean_up_passwords resource
          render json: {success:false, errors: resource.errors}, :status => :unprocessable_entity
        end

      end

      # Delete User
      # POST /api/v1/users.json
      def destroy
        current_user.destroy
        render status: 200, json: { success: true, message: "User Deleted successfully"}
      end


      protected

      def permitted_params
        params.require(:user).permit(:username, :email, :password, :password_confirmation, :remember_me)
      end

      def update_params
        params.require(:user).permit(:username, :email, :password, :password_confirmation, :current_password)
      end

      def json_request?
        request.format.json?
      end

      def validate_user
        user_signed_in? || throw(:warden, scope: :user)
      end
    end
  end
end