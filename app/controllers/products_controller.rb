class ProductsController < ApplicationController

  # methods that require an authentication to create
  before_action :require_auth, :set_current_user


  def index
    result = GetProducts.call(current_session: @current_session, wo_id: params[:wo_id])

    if result.success?
      @products = result.products
      render json: [@products], status: :ok unless @products.is_a?(Array)
    else
      render_interactor_error(result)
    end
  end

  def update
    result = SaveProductData.call(id: params[:id], product: params[:product], current_user: current_user)

    if result.success?
      render json: {product: result.product}, status: :ok

    else
      render_interactor_error(result)
    end
  end

  def get_load_details
    result = Rails.cache.fetch("global-presentation/controllers/products/get_load_details/#{params[:wo_id]}") do
      GetLoadDetails.call(current_session: @current_session, wo_id: params[:wo_id])
    end
    if result.success?
      @components = (result.components.is_a?(Array)) ? (result.components) : [result.components]
      @mould_locations = (result.mould_locations.is_a?(Array)) ? (result.mould_locations) : [result.mould_locations]
      render json: {components: @components, mould_locations: @mould_locations}, status: :ok
    else
      render_interactor_error(result)
    end
  end

  def get_finishing_data
    result = Rails.cache.fetch("global-presentation/controllers/products/get_finishing_data/#{params[:wo_id]}") do
      GetFinishingData.call(current_session: @current_session, wo_id: params[:wo_id])
    end
    if result.success?
      render json: {finishing_data: result.finishing_data}, status: :ok
    else
      render_interactor_error(result)
    end
  end

  def get_finish_packaging
    result = Rails.cache.fetch("global-presentation/controllers/products/get_finish_packaging/#{params[:wo_id]}") do
      GetFinishPackage.call(current_session: @current_session, wo_id: params[:wo_id])
    end

    if result.success?
      @finish_package = (result.finish_package.is_a?(Array)) ? (result.finish_package) : [result.finish_package]

      render json: {finish_package: result.finish_package}, status: :ok
    else
      render_interactor_error(result)
    end
  end

  def get_quality_checklist
    result = Rails.cache.fetch("global-presentation/controllers/products/get_quality_checklist/#{params[:wo_id]}") do
      GetQualityChecklist.call(current_session: @current_session, wo_id: params[:wo_id])
    end
    if result.success?
      @quality_list = (result.quality_list.is_a?(Array)) ? (result.quality_list) : [result.quality_list]

      render json: {quality_list: @quality_list}, status: :ok
    else
      render_interactor_error(result)
    end
  end


  def set_product_load
    result = SetProductLoad.call(current_session: @current_session, products: params[:products])

    if result.success?
      render json: {failures: result.failures}, status: :ok

    else

      render_interactor_error(result)
    end
  end


  def set_product_unload
    result = SetProductUnload.call(current_session: @current_session, products: params[:products])

    if result.success?
      render json: {failures: result.failures}, status: :ok

    else
      render_interactor_error(result)
    end
  end


  def set_product_finish
    result = SetProductFinish.call(current_session: @current_session, product: params[:product])

    if result.success?
      head :ok

    else
      render_interactor_error(result)
    end
  end

  def set_product_fault
    result = SetProductFault.call(current_session: @current_session, product: params[:product])

    if result.success?
      head :ok

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
