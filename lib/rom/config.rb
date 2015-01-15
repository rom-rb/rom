module ROM
  # Helper class used by ROM internally to deal with various configuration hashes
  #
  # @private
  class Config
    BASE_OPTIONS = [
      :adapter,
      :database,
      :password,
      :username,
      :hostname,
      :root
    ].freeze

    # Builds a configuration hash from a flat database config hash or a string
    #
    # This is used to support typical database.yml-complaint configs. It also
    # uses adapter interface for things that are adapter-specific like handling
    # schema naming.
    #
    # @param [Hash,String]
    #
    # @return [Hash]
    #
    # @api private
    def self.build(config, options = {})
      return config_hash(config, options) if config.is_a?(String)

      return config unless config[:database]

      root = config[:root]

      raw_scheme = config[:adapter]
      database = config[:database]
      password = config.fetch(:password) { '' }
      username = config[:username]
      hostname = config.fetch(:hostname) { 'localhost' }

      adapter = Repository[raw_scheme]
      scheme = adapter.normalize_scheme(raw_scheme)

      path =
        if adapter.database_file?(scheme)
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

    # @api private
    def self.config_hash(uri, options = {})
      if options.any?
        { default: { uri: uri, options: options } }
      else
        { default: uri }
      end
    end
  end
end
