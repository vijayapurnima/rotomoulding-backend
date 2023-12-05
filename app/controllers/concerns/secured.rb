require 'savon'

module Secured
  extend ActiveSupport::Concern


  def authorized
    return nil if request.headers['HTTP_AUTHORIZATION'].nil? || !UserSession.exists?(session_id: request.headers['HTTP_AUTHORIZATION'])
    user_session = UserSession.find_by(session_id: request.headers['HTTP_AUTHORIZATION'])
    begin
      response = @client.call(:logged_in, message: {"wsdl:SessionID": user_session.session_id})
      if response.success?
        return true
      else
        return nil
      end
    rescue Savon::Error => error
      return nil
    end
  end

  def create_session
    response = @client.call(:login, message: {
        "wsdl:GatewayKey": SystemConfig.get('accentis/key'),
        "wsdl:DBID": SystemConfig.get('accentis/dbid'),
        "wsdl:Username": SystemConfig.get('accentis/user'),
        "wsdl:Password": SystemConfig.get('accentis/password')
    })
    if response.success? && !response.body[:login_response][:login_result].nil?
      user_session = UserSession.find_by(user_name: "Global")
      user_session.session_id = response.body[:login_response][:login_result]
      user_session.save!
      user_session.session_id
    end
  rescue => error
    head :unauthorized
  end

  def get_sessionId
    user_session = UserSession.find_by(session_id: request.headers['HTTP_AUTHORIZATION'])
    user_session.session_id
  end

  def current_user
    user_session = UserSession.find_by(session_id: request.headers['HTTP_AUTHORIZATION'])
    user_session
  end

  def require_auth
    set_client
    head :unauthorized unless authorized
  end

  def get_client
    set_client
    @client
  end

  private

  def set_client
    @client = @client || Savon.client(wsdl: SystemConfig.get('accentis/wsdl'),
                                      namespace: 'http://accentis.com.au/2014/01/Gateway',
                                      namespaces: {
                                          "xmlns:arr": "http://schemas.microsoft.com/2003/10/Serialization/Arrays"})

  end
end