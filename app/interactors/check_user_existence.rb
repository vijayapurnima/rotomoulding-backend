require 'savon'

class CheckUserExistence
  include Interactor
  include Secured


  def call
    user = UserSession.find_by(user_name: context[:username].downcase)
    if user.nil? or user.session_id.nil?
      createLogin
    else
      result = CheckUserSession.call(auth_token: user.session_id)
      if  result.success?
        context[:user] = user

      else
        createLogin
      end

    end
  end


  def createLogin
    result = CreateLogin.call(username: context[:username], password: context[:password])
    if result.success?
      context[:user] = result.user_session
    else
      context.fail!(message: result.message)
    end
  end
end
