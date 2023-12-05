require 'savon'

class CreateLogin
  include Interactor
  include Secured


  def call
      begin
        client = get_client
        response = client.call(:login, message: {
            "wsdl:GatewayKey": SystemConfig.get('accentis/key'),
            "wsdl:DBID": SystemConfig.get('accentis/dbid'),
            "wsdl:Username": context[:username],
            "wsdl:Password": context[:password]
        })
        if response.success? && !response.body[:login_response][:login_result].nil? && !response.body[:login_response][:login_result].include?('ERROR')
          user_session = UserSession.find_or_create_by!(user_name: context[:username].downcase)
          user_session.session_id = response.body[:login_response][:login_result]
          user_session.save!
          context[:user_session] = user_session
          if UserSession.first.id.eql?(user_session.id) && Operation.none?
            GetOperations.call(current_session:user_session.session_id)
          end
        else
          context.fail!(message: response.body[:login_response][:login_result])
        end
      rescue Savon::Error => error
        puts error.message, error
        Raven.capture_exception(error)
        context.fail!(message: 'interactor.accentis_error')
      end
  end
end
