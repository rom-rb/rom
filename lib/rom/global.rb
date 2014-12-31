module ROM
  # Globally accessible public interface exposed via ROM module
  #
  # @public
  module Global
    # Starts the setup process for schema, relations, mappers and commands
    #
    # @param [Hash] options repository URIs
    #
    # @return [Setup] boot object
    #
    # @api public
    def setup(*args, &block)
      config = Config.build(*args)

      adapters = config.each_with_object({}) do |(name, uri_or_opts), hash|
        uri, opts =
          if uri_or_opts.is_a?(Hash)
            uri_or_opts.values_at(:uri, :options)
          else
            [uri_or_opts, {}]
          end

        hash[name] = Adapter.setup(uri, opts)
      end

      repositories = adapters.each_with_object({}) do |(name, adapter), hash|
        hash[name] = Repository.new(adapter)
      end

      boot = Setup.new(repositories)

      if block
        boot.instance_exec(&block)
        boot.finalize
      else
        @boot = boot
      end
    end

    # @api public
    def schema(&block)
      boot.schema(&block)
    end

    # @api public
    def relation(*args, &block)
      boot.relation(*args, &block)
    end

    # @api public
    def commands(*args, &block)
      boot.commands(*args, &block)
    end

    # @api public
    def mappers(*args, &block)
      boot.mappers(*args, &block)
    end

    # @api public
    def env
      @env
    end

    # @api public
    def finalize
      @env = boot.finalize
      @boot = nil
      self
    end

    private

    # @api private
    def boot
      @boot
    end
  end
end
