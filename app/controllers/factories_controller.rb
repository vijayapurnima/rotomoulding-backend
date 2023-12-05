class FactoriesController < ApplicationController


  # methods that require an authentication to create
  before_action :require_auth, :set_current_user


  def index
    result = Rails.cache.fetch("global-presentation/controllers/factories/index") do
      GetFactories.call(current_session: @current_session)
    end
    if result.success?
      @factories = result.factories
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



