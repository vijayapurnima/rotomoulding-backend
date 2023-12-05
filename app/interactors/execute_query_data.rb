require 'savon'
class ExecuteQueryData
  include Interactor
  include Secured

  def call
    begin
      client = get_client
      puts "*request sent to Accentis for QueryData operation:#{context[:message]}*"
      result = client.call(:query_data, message: context[:message])
      puts "*response received from Accentis QueryData Operation:#{result.body[:query_data_response][:query_data_result]}*"
      unless result.success? && result.body[:query_data_response][:query_data_result].eql?(true)
        context.fail!(message: 'interactor.accentis_error')
      end

    rescue Savon::Error => error
      puts error.message, error
      Raven.capture_exception(error)
      context.fail!(message: 'interactor.accentis_error')
    end
  end
end
