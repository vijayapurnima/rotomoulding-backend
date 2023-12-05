class MouldLocationsController < ApplicationController


  # methods that require an authentication to create
  before_action :require_auth, :set_current_user


  def index
    result = Rails.cache.fetch("global-presentation/controllers/mould_locations/index/#{params[:wo_id]}") do
      GetMouldLocations.call(current_session: @current_session, wo_id: params[:wo_id])
    end
    if result.success?
      @mould_locations = result.mould_locations
      render json: [@mould_locations], status: :ok unless @mould_locations.is_a?(Array)
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

