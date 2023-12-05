class TokenTouch

  def initialize(app)
    @app = app
  end

  def call(env)
    # Get the token from the header, fall back to query string param 'token':
    token = env['HTTP_AUTHENTICATION'] || Rack::Utils.parse_query(env['QUERY_STRING'], '&')['token']
    # Check token is valid
    result = /(?:Bearer:)?\s?(.+)/.match(token)
    if result
      # Reduce the input to the token
      token = result[1]
      #request = Rack::Request.new(env)
      ValidateToken.call(token: token)

      result = @app.call(env)
      result[1].merge!({
                           'X-Frame-Options' => 'SAMEORIGIN',
                           'X-Content-Type-Options' => 'nosniff',
                           'Cache-Control' => 'no-cache, no-store, must-revalidate',
                           'Pragma' => 'no-cache',
                           'Expires' => '0'
                       })
      result
    else
      @app.call(env)
    end
  end

end
