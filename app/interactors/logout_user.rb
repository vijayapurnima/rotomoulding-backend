require 'savon'

class LogoutUser
  include ExtendedInteractor
  include Secured


  def call
    after_check do
      client = get_client
      user = UserSession.find_by(session_id: context[:auth_token])
      unmapProducts(user)
      begin
        response = client.call(:logout, message: {"wsdl:SessionID": user.session_id})
        if response.success?
          return true
        else
          return false
        end
      rescue Savon::Error => error
        puts error.message, error
        Raven.capture_exception(error)
        context.fail!(message: 'interactor.logout_error')
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

  def unmapProducts(user)
    if Product.exists?(user_id: user.id)
      Product.where(user_id: user.id).each do |product|
        product.assign_attributes(user_id: nil)
        product.save!
      end
    end
  end
end
