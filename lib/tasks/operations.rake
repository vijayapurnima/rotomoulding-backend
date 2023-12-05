namespace :operations do

  desc "Push all operations retrieved from master Function of Accentis to Operations table"
  task create: :environment do
    puts 'copying Operations From Accentis'
    time = Benchmark.realtime do
      client = Savon.client(wsdl: SystemConfig.get('accentis/wsdl'),endpoint: "http://144.139.76.128:8888/AccentisConnect/General", namespace: 'http://accentis.com.au/2014/01/Gateway',namespaces: {
          "xmlns:arr": "http://schemas.microsoft.com/2003/10/Serialization/Arrays"
      })

      response = client.call(:login, message: {
          "wsdl:GatewayKey": SystemConfig.get('accentis/key'),
          "wsdl:DBID": SystemConfig.get('accentis/dbid'),
          "wsdl:Username": SystemConfig.get('accentis/user'),
          "wsdl:Password": SystemConfig.get('accentis/password')
      })

      if response.success? && !response.body[:login_response][:login_result].nil?
        sessionId = response.body[:login_response][:login_result]
        operations_result = GetOperations.call(client: client, current_session: sessionId)

        if operations_result.success?
          puts "able to get operations from accentis",operations_result.data
          operations_result.data.each do |operation|
            operationObj= Operation.find_or_create_by!(operation_name:operation[:mm_name])
            operationObj.assign_attributes(operation_id:operation[:mm_search_id])
            operationObj.save!
          end
        else
          puts "Failed to get operations from accentis"
        end

        logout_result = client.call(:logout, message: {"wsdl:SessionID": sessionId})

        if logout_result.success?
          puts "able to logout from accentis"
        else
          puts "Failed to logout from accentis"
        end
      else
        puts "Failed to create a login session for accentis"
      end
    end
    puts "Finished copying operations From Accentis #{(time / 60).floor} minutes and #{(time % 60).round(2)} seconds"
  end
end

