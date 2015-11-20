require 'rom/plugin_registry'
require 'rom/global/plugin_dsl'
require 'rom/support/deprecations'

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

      rom.instance_variable_set('@env', nil)
      rom.instance_variable_set('@adapters', {})
      rom.instance_variable_set('@plugin_registry', PluginRegistry.new)
    end

    # An internal adapter identifier => adapter module map used by setup
    #
    # @return [Hash<Symbol=>Module>]
    #
    # @api private
    attr_reader :adapters

    # An internal identifier => plugin map used by the setup
    #
    # @return [Hash]
    #
    # @api private
    attr_reader :plugin_registry

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

    def env=(container)
      @env = container
    end

    def env
      if @env.nil?
        ROM::Deprecations.announce(:env, %q{
ROM.env is no longer automatically populated with your container.
If possible, refactor your code to remove the dependency on global ROM state. If it is not
possible—or as a temporary solution—you can assign your container to `ROM.env` upon
creation:

  ROM.env = ROM.create_container(:memory) do |rom|
    ...
  end
        })
        nil
      else
        @env
      end
    end
  end
end
