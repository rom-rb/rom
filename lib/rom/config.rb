module ROM
  class Config
    BASE_OPTIONS = [
      :adapter,
      :database,
      :password,
      :username,
      :hostname,
      :root
    ].freeze

    def self.build(config)
      return config_hash(config) if config.is_a?(String)

      return config unless config[:database]

      root = config[:root]

      adapter = config[:adapter]
      database = config[:database]
      password = config[:password]
      username = config[:username]
      hostname = config.fetch(:hostname) { 'localhost' }

      scheme = Adapter[adapter].normalize_scheme(adapter)

      path =
        if root
          [root, database].compact.join('/')
        else
          db_path = [hostname, database].join('/')

          if username && password
            [[username, password].join(':'), db_path].join('@')
          else
            db_path
          end
        end

      other_keys = config.keys - BASE_OPTIONS
      options = Hash[other_keys.zip(config.values_at(*other_keys))]

      config_hash("#{scheme}://#{path}", options)
    end

    def self.config_hash(uri, options = {})
      if options.any?
        { default: { uri: uri, options: options } }
      else
        { default: uri }
      end
    end
  end
end
