class LoginsController < ApplicationController


  # Authentication is not required for these methods
  skip_before_action :require_auth, only: [:login,:loggedIn]



  # Method to authenticate user when logging into the application
  def login
    result = CheckUserExistence.call(username: params[:username], password: params[:password])
    if result.success?
      @user = result.user
      session[:current_user_id] = @user.id
    else
      render_interactor_error result
    end
  end

  # Returns the token for the current_user
  def token
    @user = current_user
    render 'logins/login'
  end

  # checks whether the userSession is LoggedIn at Accentis
  def loggedIn
    result = CheckUserSession.call(auth_token: request.headers['HTTP_AUTHORIZATION'] || request.headers['HTTP_AUTHENTICATION'])
    if result.success?
      head :ok
    else
      render_interactor_error result
    end
  end

  # Logs out the user
  def logout
    result = LogoutUser.call(auth_token: request.headers['HTTP_AUTHORIZATION'] || request.headers['HTTP_AUTHENTICATION'])
    if result.success?
      reset_session
      head :ok
    else
      render_interactor_error result
    end
  end

end
