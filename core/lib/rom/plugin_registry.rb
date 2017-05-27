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

    # @api private
    def initialize
      @configuration = ConfigurationPluginRegistry.new
      @mappers = InternalPluginRegistry.new
      @commands = InternalPluginRegistry.new
      @relations = InternalPluginRegistry.new
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
      end
    end
  end
  # Abstract registry defining common behaviour
  #
  # @api private
  class PluginRegistryBase < Registry
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
  end
  # A registry storing environment specific plugins
  #
  # @api private
  class ConfigurationPluginRegistry < PluginRegistryBase
    # Assign a plugin to this environment registry
    #
    # @param [Symbol] name The registered plugin name
    # @param [Module] mod The plugin to register
    # @param [Hash] options optional configuration data
    #
    # @api private
    def register(name, mod, options)
      elements[name] = ConfigurationPlugin.new(mod, options)
    end

    # Return an environment plugin
    #
    # @param [Symbol] name The name of the environment plugin
    #
    # @raises [UnknownPluginError] if no plugin is found with the given name
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
    # Assign a plugin to this adapter registry
    #
    # @param [Symbol] name The registered plugin name
    # @param [Module] mod The plugin to register
    # @param [Hash] options optional configuration data
    #
    # @api private
    def register(name, mod, options)
      elements[name] = Plugin.new(mod, options)
    end
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
    def initialize
      @registries = Hash.new { |h, v| h[v] = AdapterPluginRegistry.new }
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
    # @raises [UnknownPluginError] if no plugin is found with the given name
    #
    # @api public
    def fetch(name, adapter_name = :default)
      adapter(adapter_name)[name] || adapter(:default)[name] ||
        raise(UnknownPluginError, name)
    end

    alias_method :[], :fetch
  end
end
