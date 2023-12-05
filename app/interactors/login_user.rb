class LoginUser
  include ExtendedInteractor


  def call
    after_check do
      result = CreateLogin.call(username: context[:username], password: context[:password])
      if result.success?
        context[:user] = result.user_session
      else
        context.fail!(message: result.message)
      end
    end
  end

  # Checks for username and password and user associated to both prior to User Authentication
  #
  # @return [Object,nil] Returns an Error Object if check fails else nil
  def check_context
    if !context[:username] || !context[:password]
      context.fail!(message: 'auth.missing_credentials')
    end
  end
end
