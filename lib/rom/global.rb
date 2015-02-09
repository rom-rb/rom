require 'rom/setup'
require 'rom/repository'

module ROM
  # Globally accessible public interface exposed via ROM module
  #
  # @public
  module Global
    # Register adapter namespace under a specified identifier
    #
    # @param [Symbol]
    # @param [Class,Module]
    #
    # @return [self]
    #
    # @api private
    def register_adapter(identifier, adapter)
      adapters[identifier] = adapter
      self
    end

    # Return identifier => adapter map
    #
    # @return [Hash]
    #
    # @api private
    def adapters
      @__adapters__ ||= {}
    end

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
      boot = Setup.new(setup_repositories(config), adapters.keys.first)

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

    # @api private
    def repositories
      @repositories ||= {}
    end

    private

    # @api private
    def boot
      @boot
    end

    # @api private
    def setup_config(*args)
      # Support simple single-repository setups.
      args.first.is_a?(Hash) ? args.first : { default: args }
    end

    # @api private
    def setup_repositories(config)
      config.each_with_object({}) do |(name, spec), hash|
        identifier, *args = Array(spec)
        repository = Repository.setup(identifier, *args)
        hash[name] = repository

        repositories[repository] = identifier unless identifier.is_a?(Repository)
      end
    end
  end
end
