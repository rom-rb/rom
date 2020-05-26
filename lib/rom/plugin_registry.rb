# frozen_string_literal: true

require 'concurrent/map'
require 'rom/registry'
require 'rom/plugins'

module ROM
  # Stores all registered plugins
  #
  # @api private
  class PluginRegistry
    # @api private
    attr_reader :types

    # @api private
    def initialize
      @types = ::Concurrent::Map.new
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
      type(options.fetch(:type)).register(name, mod, options)
    end

    # @api private
    def type(type)
      types.fetch_or_store(type) do
        if Plugins[type][:adapter]
          AdapterPluginsContainer.new(type)
        else
          PluginsContainer.new({}, type: type)
        end
      end
    end

    # @api private
    def [](type)
      types.fetch(singularize(type))
    end

    # Old API compatibility
    #
    # @api private
    def singularize(type)
      case type
      when :relations then :relation
      when :commands then :command
      when :mappers then :mapper
      when :schemas then :schema
      else type
      end
    end
  end

  # Abstract registry defining common behaviour
  #
  # @api private
  class PluginsContainer < Registry
    include Dry::Equalizer(:elements, :type)

    # @!attribute [r] plugin_type
    #   @return [Class] Typically ROM::PluginBase or its descendant
    option :type

    # Assign a plugin to this environment registry
    #
    # @param [Symbol] name The registered plugin name
    # @param [Module] mod The plugin to register
    # @param [Hash] options optional configuration data
    #
    # @api private
    def register(name, mod, options)
      elements[name] = plugin_type.new(name, mod, **options)
    end

    # @api private
    def plugin_type
      Plugins[type][:plugin_type]
    end
  end

  # Store a set of registries grouped by adapter
  #
  # @api private
  class AdapterPluginsContainer
    # Return the existing registries
    #
    # @return [Hash]
    #
    # @api private
    attr_reader :registries

    # @api private
    attr_reader :type

    # @api private
    def initialize(type)
      @registries = ::Hash.new { |h, v| h[v] = PluginsContainer.new({}, type: type) }
      @type = type
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

    # @api private
    def register(name, mod, options)
      adapter(options.fetch(:adapter, :default)).register(name, mod, options)
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
      adapter(adapter_name).fetch(name) do
        adapter(:default).fetch(name) do
          raise(UnknownPluginError, name)
        end
      end
    end

    alias_method :[], :fetch
  end
end
