require 'rom/support/registry'

module ROM
  # Stores all registered plugins
  #
  # @api private
  class PluginRegistry

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
      @mappers    = InternalPluginRegistry.new
      @commands   = InternalPluginRegistry.new
      @relations  = InternalPluginRegistry.new
    end

    # Register a plugin for future use
    #
    # @param [Symbol] name The registration name for the plugin
    # @param [Module] mod The plugin to register
    # @param [Hash] options optional configuration data
    # @option options [Symbol] :type What type of plugin this is (command, relation or mapper)
    # @option options [Symbol] :adapter (:default) which adapter this plugin applies to. Leave blank for all adapters
    def register(name, mod, options = {})
      type    = options.fetch(:type)
      adapter = options.fetch(:adapter, :default)

      plugins_for(type, adapter)[name] = Plugin.new(mod, options)
    end

    private

    # Determine which specific registry to use
    #
    # @api private
    def plugins_for(type, adapter)
      case type
      when :command   then commands.adapter(adapter)
      when :mapper    then mappers.adapter(adapter)
      when :relation  then relations.adapter(adapter)
      end
    end
  end

  # A registry storing specific plugins
  #
  # @api private
  class AdapterPluginRegistry < Registry

    # Assign a plugin to this adapter registry
    #
    # @param [Symbol] name The registered plugin name
    # @param [Plugin] plugin The plugin to register
    #
    # @api private
    def []=(name, plugin)
      elements[name] = plugin
    end

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
      @registries = Hash.new{|h,v| h[v] = AdapterPluginRegistry.new }
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
    # @param [Symbol] adapter (:default) The name of the adapter used
    #
    # @raises [UnknownPluginError] if no plugin is found with the given name
    #
    # @api public
    def fetch(name, adapter_name = :default)
      adapter(adapter_name)[name] || adapter(:default)[name] ||
        raise(UnknownPluginError, name) 
    end

    alias [] fetch
  end


end
