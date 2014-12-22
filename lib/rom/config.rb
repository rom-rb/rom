module ROM
  class Config
    def self.build(config)
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

      { default: "#{scheme}://#{path}" }
    end
  end
end
