class SystemConfig

  DEV_VALUES = {
      'accentis/wsdl': ENV['ACCE_SERVICE_WSDL'] || 'http://accentis.globalwater.com.au:8888/AccentisConnect/API?wsdl',
      'accentis/namespace': ENV['ACCE_SERVICE_NAMESPACE'] || 'http://accentis.com.au/2014/01/Gateway',
      'accentis/user': ENV['ACCE_SERVICE_USER'] || 'MobileApp',
      'accentis/password': ENV['ACCE_SERVICE_PASSWORD'] || 'M0b!l3Appl!cat!0n',
      'accentis/key': ENV['ACCE_SERVICE_KEY'] || 123,
      'accentis/dbid': ENV['ACCE_SERVICE_DBID'] || 1570094592,
      'accentis/master_id': ENV['ACCE_SERVICE_MASTER_ID'] || 1100196

  }

  def self.get key
    return nil if key.nil?
    if Rails.env.development? || Rails.env.test? || Rails.env.docker?
      DEV_VALUES[key.to_sym]
    else
      ssm_key = "/#{ENV['ENVIRONMENT']}/#{key}"
      Rails.cache.fetch("/config#{ssm_key}", expires_in: 1.hour) do
        get_raw(ssm_key)
      end
    end
  end

  def self.get_raw ssm_key
    ssm = Aws::SSM::Client.new
    response = ssm.get_parameter({name: ssm_key})
    response.parameter.value
  end

end