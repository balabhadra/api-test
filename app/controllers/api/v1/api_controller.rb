# Base class for all api controllers except for session and registration which are subclassed from devise.
# This class is derived from ActionController::Base.
module Api
  module V1
    class ApiController < ::ActionController::Base
      
      # Define which model will act as token authenticatable. Used to authenticate via token
      # https://github.com/gonzalo-bulnes/simple_token_authentication
      acts_as_token_authentication_handler_for User, fallback_to_devise: false

    end
  end
end