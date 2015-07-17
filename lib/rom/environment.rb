require 'rom/setup'
require 'rom/repository'
require 'rom/plugin_registry'

require 'rom/environment/plugin_dsl'

module ROM
  # Globally accessible public interface exposed via ROM module
  #
  # @api public
  class Environment
    # @api private
    def initialize
      @adapters = {}
      @gateways = {}
      @plugin_registry = PluginRegistry.new
    end
    # An internal adapter identifier => adapter module map used by setup
    #
    # @return [Hash<Symbol=>Module>]
    #
    # @api private
    attr_reader :adapters

    # An internal gateway => identifier map used by the setup
    #
    # @return [Hash]
    #
    # @api private
    attr_reader :gateways

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
    #   Sets up a single-gateway environment given a gateway type provided
    #   under the ROM umbrella. For custom gateways, create an instance and
    #   pass it directly.
    #
    #   @param [Symbol] type
    #   @param [Array] *args
    #
    # @overload setup(gateway)
    #   @param [Gateway] gateway
    #
    # @overload setup(gateways)
    #   Sets up multiple gateways.
    #
    #   @param [Hash{Symbol=>Symbol,Array}] gateways
    #
    # @return [Setup] boot object
    #
    # @example
    #   # Use the in-memory adapter shipped with ROM as the default gateway.
    #   rom = ROM::Environment.new
    #   env = rom.setup(:memory, 'memory://test')
    #   # Use `rom-sql` with an in-memory sqlite database as default gateway.
    #   rom.setup(:sql, 'sqlite::memory')
    #   # Registers a `default` and a `warehouse` gateway.
    #   env = rom.setup(
    #     default: [:sql, 'sqlite::memory'],
    #     warehouse: [:sql, 'postgres://localhost/warehouse']
    #   )
    #
    # @example A full environment
    #
    #   rom = ROM::Environment.new
    #   rom.setup(:memory, 'memory://test')
    #
    #   rom.relation(:users) do
    #     # ...
    #   end
    #
    #   rom.mappers do
    #     define(:users) do
    #       # ...
    #     end
    #   end
    #
    #   rom.commands(:users) do
    #     define(:create) do
    #       # ...
    #     end
    #   end
    #
    #   rom.finalize # builds the env
    #   rom.env # returns the env registry
    #
    # @api public
    def setup(*args, &block)
      config = setup_config(*args)
      @boot = Setup.new(setup_gateways(config), adapters.keys.first)

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
    #   rom = ROM::Environment.new
    #   rom.setup(:memory)
    #
    #   rom.relation(:users) do
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
    #   rom = ROM::Environment.new
    #   rom.setup(:memory)
    #
    #   rom.commands(:users) do
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
    #   rom = ROM::Environment.new
    #   rom.setup(:memory)
    #
    #   rom.mappers do
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
    #   rom = ROM::Environment.new
    #   rom.plugins do
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
    #   rom = ROM::Environment.new
    #   rom.setup(:memory)
    #   rom.finalize # => rom
    #   rom.boot # => nil
    #   rom.env # => the env
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

    # Build gateways using the setup interface
    #
    # @api private
    def setup_gateways(config)
      config.each_with_object({}) do |(name, spec), hash|
        identifier, *args = Array(spec)
        gateway = Gateway.setup(identifier, *(args.flatten))
        hash[name] = gateway

        gateways[gateway] = identifier unless identifier.is_a?(Gateway)
      end
    end
  end
end
