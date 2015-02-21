# Overriding devise's Session Controller
module Api
  module V1
    class SessionsController < ::Devise::SessionsController
      
      acts_as_token_authentication_handler_for User, only: [:destroy], fallback_to_devise: false
           
      respond_to :json 
      
      # skip_before_filter :authenticate_user!
      skip_before_filter :verify_authenticity_token, if: :json_request?   
    
      # skip_before_filter :authenticate_entity_from_token!
      #       skip_before_filter :authenticate_entity!
      #       before_filter :authenticate_entity_from_token!, :only => [:destroy]
      #       before_filter :authenticate_entity!, :only => [:destroy]

      def create
        binding.pry
        auth_options = {scope: resource_name, recall: "#{controller_path}#failure"}
        self.resource = warden.authenticate!(auth_options)     
        @user = current_user
      end

      def destroy
        @user = current_user
        @user.authentication_token = nil
        @user.save
      end

      def failure
      end
      
private
      
      def json_request?
        request.format.json?
      end
      
    end
  end
end
