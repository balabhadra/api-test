module Api
  module V1
    class RegistrationsController < ::Devise::RegistrationsController
      respond_to :json
      skip_before_filter :verify_authenticity_token, if: :json_request?
      skip_before_filter :authenticate_scope!, :only => [:update, :destroy]

      acts_as_token_authentication_handler_for User, only: [:update, :destroy], fallback_to_devise: false

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
      # PATCH /api/v1/users/1.json
      def update
        if user_signed_in?
          # Get a copy of current user
          self.resource = resource_class.to_adapter.get!(send(:"current_user").to_key)
          resource_updated = update_resource(resource, update_params)
          if resource_updated
            render json: {success: true, user: resource}
          else
            clean_up_passwords resource
            render json: {success:false, errors: resource.errors}, :status => :unprocessable_entity
          end
        else
          render status: 401, json: { success: false, message: 'Failed to update. You must be logged in.'}
        end
      end
      
      # Delete User
      # POST /api/v1/users.json
      def destroy
        if user_signed_in?
          current_user.destroy
          render status: 200, json: { success: true, message: "User Deleted successfully"}
        else
          render status: 401, json: { success: false, message: 'Failed to log out. You must be logged in.'}
        end
      end

      private

      def permitted_params
        params.require(:user).permit(:username, :email, :password, :password_confirmation, :remember_me)
      end
      
      def update_params
        params.require(:user).permit(:username, :email, :password, :password_confirmation, :current_password)
      end

      def json_request?
        request.format.json?
      end
    end
  end
end