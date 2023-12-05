class UsersController < ApplicationController

  # methods that require an authentication to create
  before_action :require_auth, :set_current_user


  def get_staff
    result = Rails.cache.fetch("global-presentation/controllers/users/get_staff") do
      GetStaffMembers.call(current_session: @current_session)
    end
    if result.success?
      @staff = result.staff
      (@staff.is_a?(Array)) ? (render 'staff/index') : (render json: [@staff], status: :ok)
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

