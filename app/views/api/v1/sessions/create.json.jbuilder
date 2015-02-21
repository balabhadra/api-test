json.success true
json.data do
  json.auth_token @user.authentication_token
  json.message "login successful"
end