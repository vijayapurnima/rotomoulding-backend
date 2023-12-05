json.user do
  json.id @user.id
  json.name @user.user_name
  json.auth_token @user.session_id
end