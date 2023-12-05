require 'savon'

class CheckUserSession
  include ExtendedInteractor
  include Secured


  def call
    after_check do
      client = get_client
      user = UserSession.find_by(session_id: context[:auth_token])
      begin
        response = client.call(:logged_in, message: {"wsdl:SessionID": user.session_id})
        if response.success?
          return true
        else
          reset_product_locks(user) unless user.nil?
          return false
        end
      rescue Savon::Error => error
        puts error.message, error
        Raven.capture_exception(error)
        reset_product_locks(user) unless user.nil?
        context.fail!(message: 'interactor.accentis_error')
      end
    end
  end

  # Checks for username and password and user associated to both prior to User Authentication
  #
  # @return [Object,nil] Returns an Error Object if check fails else nil
  def check_context
    if context[:auth_token].nil? || !UserSession.exists?(session_id: context[:auth_token])
      context.fail!(message: 'auth.missing_credentials')
    end
  end

  def reset_product_locks(user)
    Product.where(user_id: user.id).each do |pr|
      pr.user_id = nil
      pr.save!
    end
  end
end
