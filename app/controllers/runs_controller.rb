class RunsController < ApplicationController

  # methods that require an authentication to create
  before_action :require_auth, :set_current_user


  def index
    result = GetRuns.call(current_session: @current_session,arm_id:params[:arm_id])

    if result.success?
      @runs = (result.runs.is_a?(Array))?(result.runs):[result.runs]
      render json: @runs, status: :ok
    else
      render_interactor_error(result)
    end
  end


  def create
    result = CreateRun.call(run:params[:run],current_user:current_user)

    if result.success?
      @run = result.run
      render json: @run , status: :ok
    else
      render_interactor_error(result)
    end
  end

  def update
    result = UpdateRun.call(id:params[:id],run:params[:run],current_user:current_user)

    if result.success?
      @run = result.run
      render json: @run, status: :ok
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
