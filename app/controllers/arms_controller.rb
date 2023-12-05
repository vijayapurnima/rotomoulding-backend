class ArmsController < ApplicationController

  # methods that require an authentication to create
  before_action :require_auth, :set_current_user


  def index
    result = GetArms.call(current_session: @current_session,oven_id:params[:oven_id],current_user:current_user)

    if result.success?
      @arms = result.arms
      render json: [{id: @arms[:arm_id],name: @arms[:arm_name]}], status: :ok unless @arms.is_a?(Array)
    else
      render_interactor_error(result)
    end
  end


  private

  # Method which will set the current_user prior to all calls which need authentication
  #
  # @return [JSON]
  # @rest_return User [Object] User Object with details
  # @rest_return error_message [String] A message only returned when retrieving Current User failed
  def set_current_user
    @current_session = get_sessionId
  end

end
