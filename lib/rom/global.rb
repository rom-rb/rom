module ROM
  # Globally accessible public interface exposed via ROM module
  #
  # @public
  module Global
    # Starts the setup process for relations, mappers and commands.
    #
    # @overload setup(type, *args)
    #   Sets up a single-repository environment given a repository type provided
    #   under the ROM umbrella. For custom repositories, create an instance and
    #   pass it directly.
    #
    #   @param [Symbol] type
    #   @param [Array] *args
    #
    # @overload setup(repository)
    #   @param [Repository] repository
    #
    # @overload setup(repositories)
    #   Sets up multiple repositories.
    #
    #   @param [Hash{Symbol=>Symbol,Array}] repositories
    #
    # @return [Setup] boot object
    #
    # @example
    #   # Use the in-memory adapter shipped with ROM as the default repository.
    #   env = ROM.setup(:memory, 'memory://test')
    #   # Use `rom-sql` with an in-memory sqlite database as default repository.
    #   ROM.setup(:sql, 'sqlite::memory')
    #   # Registers a `default` and a `warehouse` repository.
    #   env = ROM.setup(
    #     default: [:sql, 'sqlite::memory'],
    #     warehouse: [:sql, 'postgres://localhost/warehouse']
    #   )
    #
    # @example A full environment
    #
    #   ROM.setup(:memory, 'memory://test')
    #
    #   ROM.relation(:users) do
    #     # ...
    #   end
    #
    #   ROM.mappers do
    #     define(:users) do
    #       # ...
    #     end
    #   end
    #
    #   ROM.commands(:users) do
    #     define(:create) do
    #       # ...
    #     end
    #   end
    #
    #   ROM.finalize # builds the env
    #   ROM.env # returns the env registry
    #
    # @api public
    def setup(*args, &block)
      config = setup_config(*args)
      repositories = setup_repostories(config)
      boot = Setup.new(repositories)

      if block
        boot.instance_exec(&block)
        boot.finalize
      else
        @boot = boot
      end
    end

    # @see ROM::Setup#relation
    #
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

    # @api private
    def setup_config(*args)
      # Support simple single-repository setups.
      args.first.is_a?(Hash) ? args.first : {default: args}
    end

    # @api private
    def setup_repostories(config)
      config.each_with_object({}) do |(name, spec), hash|
        repository, *args = *Array(spec)
        hash[name] = Repository.setup(repository, *args)
      end
    end
  end
end
