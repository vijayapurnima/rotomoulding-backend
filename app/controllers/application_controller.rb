class ApplicationController < ActionController::API
  include Secured
  include ActionController::ImplicitRender

  before_action :require_auth
  # https://stackoverflow.com/questions/711418/how-to-prevent-browser-page-caching-in-rails
  before_action :set_cache_headers

  def render_interactor_error(result)
    message = I18n.t(result[:message]).include?("translation missing") ? result[:message] : I18n.t(result[:message])

    result[:json] = {code: result[:message], description: message}
    result[:status] ||= :unprocessable_entity

    render json: result[:json], status: result[:status]
  end

  private

  def set_cache_headers
    response.headers["Cache-Control"] = "no-cache, no-store"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end
end
