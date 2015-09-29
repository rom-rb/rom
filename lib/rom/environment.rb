require 'rom/setup'
require 'rom/repository'

module ROM
  # Globally accessible public interface exposed via ROM module
  #
  # @api public
  class Environment
    # An internal gateway => identifier map used by the setup
    #
    # @return [Hash]
    #
    # @api private
    attr_reader :gateways

    # Setup object created during setup phase
    #
    # This gets set to nil after setup is finalized
    #
    # @return [Setup]
    #
    # @api private
    attr_reader :boot

    # Return ROM container configured by the setup
    #
    # @return [Container]
    #
    # @api public
    attr_reader :container
    alias_method :env, :container

    # @api private
    def initialize
      @gateways = {}
    end

    # @api private
    def adapters
      ROM.adapters
    end

    # @api private
    def plugin_registry
      ROM.plugin_registry
    end

    # Apply a plugin to the environment
    #
    # @param [Mixed] The plugin identifier, usually a Symbol
    # @param [Hash] Plugin options
    #
    # @api public
    def use(plugin, options = {})
      plugin_registry.environment.fetch(plugin).apply_to(self, options)
    end

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
    #   rom.finalize # builds the container
    #   rom.container # returns the container registry
    #
    # @api public
    def setup(*args, &block)
      config = setup_config(*args)
      configured_gateways = setup_gateways(config)

      default_adapter = gateways.fetch(
        configured_gateways[:default], adapters.keys.first
      )

      @boot = Setup.new(configured_gateways,
        gateway_map: gateways,
        default_adapter: default_adapter
                       )

      config.each do |name, config_args|
        options = config_args.is_a?(Array) && config_args.last
        load_config(@boot.config.gateways[name], options) if options.is_a?(Hash)
      end

      if block
        use :auto_registration unless auto_registration?
        @boot.instance_exec(&block)
        finalize.container
      else
        @boot
      end
    end

    # Check if auto-registration is enabled for this environment
    #
    # @api private
    def auto_registration?
      false
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

    # Null boot object installed upon finalization.
    class FinalizedBoot
      def register_relation(klass)
        raise ROM::EnvAlreadyFinalizedError
      end

      def register_mapper(klass)
        raise ROM::EnvAlreadyFinalizedError
      end

      def register_command(klass)
        raise ROM::EnvAlreadyFinalizedError
      end
    end

    # Finalize the setup and store default global container under
    # ROM::Environment#container
    #
    # @example
    #   rom = ROM::Environment.new
    #   rom.setup(:memory)
    #   rom.finalize # => rom
    #   rom.boot # => nil
    #   rom.container # => the container
    #
    # @return [ROM]
    #
    # @api public
    def finalize
      @container = boot.finalize
      self
    ensure
      @boot = FinalizedBoot.new
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

    # Return gateway config that was used to setup this environment's container
    #
    # @return [Configurable::Config]
    #
    # @api public
    def config
      boot.config
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

    # @api private
    def load_config(config, hash)
      hash.each do |key, value|
        if value.is_a?(Hash)
          load_config(config[key], value)
        else
          config.send("#{key}=", value)
        end
      end
    end
  end
end
