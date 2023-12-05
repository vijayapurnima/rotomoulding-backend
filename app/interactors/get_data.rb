require 'savon'
class GetData
  include Interactor
  include Secured

  def call
    begin
      client = get_client
      result = client.call(:data, message: context[:message])
      if result.success?
        context[:data] = []
        context[:data] = result.body[:data_response][:data_result][:diffgram][:document_element][:aec_data] unless result.body[:data_response][:data_result][:diffgram][:document_element].nil?
      else
        context.fail!(message: 'interactor.accentis_error')
      end
    rescue Savon::Error => error
      puts error.message, error.response
      Raven.capture_exception(error)
      context.fail!(message: 'interactor.accentis_error')
    end
  end
end
