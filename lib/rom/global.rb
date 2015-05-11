require 'rom/setup'
require 'rom/repository'
require 'rom/plugin_registry'

require 'rom/global/plugin_dsl'

module ROM
  # Globally accessible public interface exposed via ROM module
  #
  # @api public
  module Global
    # Set base global registries in ROM constant
    #
    # @api private
    def self.extended(rom)
      super

      rom.instance_variable_set('@adapters', {})
      rom.instance_variable_set('@repositories', {})
      rom.instance_variable_set('@plugin_registry', PluginRegistry.new)
    end

    # An internal adapter identifier => adapter module map used by setup
    #
    # @return [Hash<Symbol=>Module>]
    #
    # @api private
    attr_reader :adapters

    # An internal repo => identifier map used by the setup
    #
    # @return [Hash]
    #
    # @api private
    attr_reader :repositories

    # An internal identifier => plugin map used by the setup
    #
    # @return [Hash]
    #
    # @api private
    attr_reader :plugin_registry

    # Setup object created during env setup phase
    #
    # This gets set to nil after setup is finalized
    #
    # @return [Setup]
    #
    # @api private
    attr_reader :boot

    # Return global default ROM environment configured by the setup
    #
    # @return [Env]
    #
    # @api public
    attr_reader :env

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
      @boot = Setup.new(setup_repositories(config), adapters.keys.first)

      if block
        @boot.instance_exec(&block)
        @boot.finalize
      else
        @boot
      end
    end

    # Global relation setup DSL
    #
    # @example
    #   ROM.setup(:memory)
    #
    #   ROM.relation(:users) do
    #     def by_name(name)
    #       restrict(name: name)
    #     end
    #   end
    #
    # @api public
    def relation(*args, &block)
      boot.relation(*args, &block)
    end

    # Global commands setup DSL
    #
    # @example
    #   ROM.setup(:memory)
    #
    #   ROM.commands(:users) do
    #     define(:create) do
    #       # ..
    #     end
    #   end
    #
    # @api public
    def commands(*args, &block)
      boot.commands(*args, &block)
    end

    # Global mapper setup DSL
    #
    # @example
    #   ROM.setup(:memory)
    #
    #   ROM.mappers do
    #     define(:uses) do
    #       # ..
    #     end
    #   end
    #
    # @api public
    def mappers(*args, &block)
      boot.mappers(*args, &block)
    end

    # Global plugin setup DSL
    #
    # @example
    #   ROM.plugins do
    #     register :publisher, Plugin::Publisher, type: :command
    #   end
    #
    # @example
    def plugins(*args, &block)
      PluginDSL.new(plugin_registry, *args, &block)
    end

    # Finalize the setup and store default global env under ROM.env
    #
    # @example
    #   ROM.setup(:memory)
    #   ROM.finalize # => ROM
    #   ROM.boot # => nil
    #   ROM.env # => the env
    #
    # @return [ROM]
    #
    # @api public
    def finalize
      @env = boot.finalize
      self
    ensure
      @boot = nil
    end

    # Register adapter namespace under a specified identifier
    #
    # @param [Symbol] identifier
    # @param [Class,Module] adapter
    #
    # @return [self]
    #
    # @api private
    def register_adapter(identifier, adapter)
      adapters[identifier] = adapter
      self
    end

    # Relation subclass registration during setup phase
    #
    # @api private
    def register_relation(klass)
      boot.register_relation(klass) if boot
    end

    # Mapper subclass registration during setup phase
    #
    # @api private
    def register_mapper(klass)
      boot.register_mapper(klass) if boot
    end

    # Command subclass registration during setup phase
    #
    # @api private
    def register_command(klass)
      boot.register_command(klass) if boot
    end

    private

    # Helper method to handle single- or multi-repo setup options
    #
    # @api private
    def setup_config(*args)
      args.first.is_a?(Hash) ? args.first : { default: args }
    end

    # Build repositories using the setup interface
    #
    # @api private
    def setup_repositories(config)
      config.each_with_object({}) do |(name, spec), hash|
        identifier, *args = Array(spec)
        repository = Repository.setup(identifier, *(args.flatten))
        hash[name] = repository

        repositories[repository] = identifier unless identifier.is_a?(Repository)
      end
    end
  end
end
