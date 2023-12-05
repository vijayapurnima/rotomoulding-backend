class FaultsController < ApplicationController

  # methods that require an authentication to create
  before_action :require_auth, :set_current_user


  def get_fault_types
    result = Rails.cache.fetch("global-presentation/controllers/faults/get_fault_types", expires_in: 1.days) do
      GetFaultTypes.call(current_session: @current_session)
    end
    if result.success?
      @fault_types = (result.fault_types.is_a?(Array)) ? (result.fault_types) : [result.fault_types]

      render json: {fault_types: @fault_types}, status: :ok
    else
      render_interactor_error(result)
    end
  end

  def get_fault_reasons
    result = Rails.cache.fetch("global-presentation/controllers/faults/get_fault_reasons") do
      GetFaultReasons.call(current_session: @current_session)
    end
    if result.success?
      @fault_reasons = (result.fault_reasons.is_a?(Array)) ? (result.fault_reasons) : [result.fault_reasons]

      render json: {fault_reasons: @fault_reasons}, status: :ok
    else
      render_interactor_error(result)
    end
  end


  def get_fault_categories
    result = Rails.cache.fetch("global-presentation/controllers/faults/get_fault_categories") do
      GetFaultCategories.call(current_session: @current_session)
    end
    if result.success?
      @fault_categories = (result.fault_categories.is_a?(Array)) ? (result.fault_categories) : [result.fault_categories]

      render json: {fault_categories: @fault_categories}, status: :ok
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
