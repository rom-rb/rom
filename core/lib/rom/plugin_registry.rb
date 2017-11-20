require 'rom/registry'

module ROM
  # Stores all registered plugins
  #
  # @api private
  class PluginRegistry
    # Internal registry for configuration plugins
    #
    # @return [ConfigurationPluginRegistry]
    #
    # @api private
    attr_reader :configuration

    # Internal registry for command plugins
    #
    # @return [InternalPluginRegistry]
    #
    # @api private
    attr_reader :commands

    # Internal registry for mapper plugins
    #
    # @return [InternalPluginRegistry]
    #
    # @api private
    attr_reader :mappers

    # Internal registry for relation plugins
    #
    # @return [InternalPluginRegistry]
    #
    # @api private
    attr_reader :relations

    # Internal registry for schema plugins
    #
    # @return [InternalPluginRegistry]
    #
    # @api private
    attr_reader :schemas

    # @api private
    def initialize
      @configuration = ConfigurationPluginRegistry.new
      @mappers = InternalPluginRegistry.new
      @commands = InternalPluginRegistry.new
      @relations = InternalPluginRegistry.new
      @schemas = InternalPluginRegistry.new(SchemaPlugin)
    end

    # Register a plugin for future use
    #
    # @param [Symbol] name The registration name for the plugin
    # @param [Module] mod The plugin to register
    # @param [Hash] options optional configuration data
    # @option options [Symbol] :type What type of plugin this is (command,
    # relation or mapper)
    # @option options [Symbol] :adapter (:default) which adapter this plugin
    # applies to. Leave blank for all adapters
    def register(name, mod, options = EMPTY_HASH)
      type    = options.fetch(:type)
      adapter = options.fetch(:adapter, :default)

      plugins_for(type, adapter).register(name, mod, options)
    end

    private

    # Determine which specific registry to use
    #
    # @api private
    def plugins_for(type, adapter)
      case type
      when :configuration then configuration
      when :command       then commands.adapter(adapter)
      when :mapper        then mappers.adapter(adapter)
      when :relation      then relations.adapter(adapter)
      when :schema        then schemas.adapter(adapter)
      end
    end
  end

  # Abstract registry defining common behaviour
  #
  # @api private
  class PluginRegistryBase < Registry
    include Dry::Equalizer(:elements, :plugin_type)

    # @!attribute [r] plugin_type
    #   @return [Class] Typically ROM::PluginBase or its descendant
    option :plugin_type

    # Retrieve a registered plugin
    #
    # @param [Symbol] name The plugin to retrieve
    #
    # @return [Plugin]
    #
    # @api public
    def [](name)
      elements[name]
    end

    # Assign a plugin to this environment registry
    #
    # @param [Symbol] name The registered plugin name
    # @param [Module] mod The plugin to register
    # @param [Hash] options optional configuration data
    #
    # @api private
    def register(name, mod, options)
      elements[name] = plugin_type.new(mod, options)
    end

    # Returns plugin name by instance
    #
    # @return [Symbol] Plugin name
    #
    # @api private
    def plugin_name(plugin)
     tuple = elements.find { |(_, p)| p.equal?(plugin) }
     tuple[0] if tuple
    end
  end

  # A registry storing environment specific plugins
  #
  # @api private
  class ConfigurationPluginRegistry < PluginRegistryBase
    # @api private
    def initialize(*args, **kwargs)
      super(*args, **kwargs, plugin_type: ConfigurationPlugin)
    end

    # Return an environment plugin
    #
    # @param [Symbol] name The name of the environment plugin
    #
    # @raise [UnknownPluginError] if no plugin is found with the given name
    #
    # @api public
    def fetch(name)
      self[name] || raise(UnknownPluginError, name)
    end
  end

  # A registry storing adapter specific plugins
  #
  # @api private
  class AdapterPluginRegistry < PluginRegistryBase
    option :plugin_type, default: -> { Plugin }
  end

  # Store a set of registries grouped by adapter
  #
  # @api private
  class InternalPluginRegistry
    # Return the existing registries
    #
    # @return [Hash]
    #
    # @api private
    attr_reader :registries

    # @api private
    def initialize(plugin_type = Plugin)
      @registries = Hash.new { |h, v| h[v] = AdapterPluginRegistry.new({}, plugin_type: plugin_type) }
    end

    # Return the plugin registry for a specific adapter
    #
    # @param [Symbol] name The name of the adapter
    #
    # @return [AdapterRegistry]
    #
    # @api private
    def adapter(name)
      registries[name]
    end

    # Return the plugin for a given adapter
    #
    # @param [Symbol] name The name of the plugin
    # @param [Symbol] adapter_name (:default) The name of the adapter used
    #
    # @raise [UnknownPluginError] if no plugin is found with the given name
    #
    # @api public
    def fetch(name, adapter_name = :default)
      adapter(adapter_name)[name] || adapter(:default)[name] ||
        raise(UnknownPluginError, name)
    end

    alias_method :[], :fetch
  end
end
