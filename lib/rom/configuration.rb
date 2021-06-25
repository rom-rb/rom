# frozen_string_literal: true

require "forwardable"

require "rom/support/notifications"
require "rom/setup"
require "rom/configuration_dsl"
require "rom/support/configurable"
require "rom/support/inflector"

module ROM
  class Configuration
    extend Forwardable
    extend Notifications

    register_event("configuration.relations.class.ready")
    register_event("configuration.relations.object.registered")
    register_event("configuration.relations.registry.created")
    register_event("configuration.relations.schema.allocated")
    register_event("configuration.relations.schema.set")
    register_event("configuration.relations.dataset.allocated")
    register_event("configuration.commands.class.before_build")

    include ROM::ConfigurationDSL
    include Configurable

    NoDefaultAdapterError = Class.new(StandardError)

    # @!attribute [r] setup
    #   @return [Setup] Setup object which manages component and plugins
    attr_reader :setup

    # @!attribute [r] notifications
    #   @return [Notifications] Notification bus instance
    attr_reader :notifications

    def_delegators :@setup, :cache, :relations, :gateways,
      :register_relation, :register_command, :register_mapper,
      :register_plugin, :auto_register, :inflector, :inflector=,
      :components, :plugins

    # Initialize a new configuration
    #
    # @return [Configuration]
    #
    # @api private
    def initialize(*args, &block)
      @notifications = Notifications.event_bus(:configuration)

      config.gateways = Config.new
      @setup = Setup.new(config: config.gateways)

      configure(*args, &block)
    end

    # @api public
    def configure(*args)
      unless args.empty?
        gateways_config = args.first.is_a?(Hash) ? args.first : {default: args}

        gateways_config.each do |name, value|
          args = Array(value)

          adapter, *rest = args

          if rest.size > 1 && rest.last.is_a?(Hash)
            load_config(config.gateways[name], {adapter: adapter, args: rest[0..-1], **rest.last})
          else
            options = rest.first.is_a?(Hash) ? rest.first : {args: rest.flatten(1)}
            load_config(config.gateways[name], {adapter: adapter, **options})
          end
        end
      end

      # Load adapters explicitly here to ensure their plugins are present already
      # while setup loads components and then triggers finalization
      setup.load_adapters

      yield(self) if block_given?

      # No more changes allowed
      config.freeze

      # Load gateways after yielding config because gateways *need finalized config*
      setup.load_gateways

      self
    end

    # @api private
    def finalize
      setup.finalize
      self
    end

    # Apply a plugin to the configuration
    #
    # @param [Mixed] plugin The plugin identifier, usually a Symbol
    # @param [Hash] options Plugin options
    #
    # @return [Configuration]
    #
    # @api public
    def use(plugin, options = {})
      case plugin
      when Array then plugin.each { |p| use(p) }
      when Hash then plugin.to_a.each { |p| use(*p) }
      else
        ROM.plugin_registry[:configuration].fetch(plugin).apply_to(self, options)
      end

      self
    end

    # Return gateway identified by name
    #
    # @return [Gateway]
    #
    # @api private
    def [](name)
      gateways.fetch(name)
    end

    # @api private
    def default_gateway
      @default_gateway ||= gateways[:default] if gateways.key?(:default)
    end

    # @api private
    def default_adapter
      @default_adapter ||= adapter_for_gateway(default_gateway) || ROM.adapters.keys.first
    end

    # @api private
    def adapter_for_gateway(gateway)
      ROM.adapters.select do |_key, value|
        value.const_defined?(:Gateway) && gateway.is_a?(value.const_get(:Gateway))
      end.keys.first
    end

    # @api private
    def command_compiler
      @command_compiler ||= CommandCompiler.new(
        gateways,
        relations,
        Registry.new,
        notifications,
        inflector: inflector
      )
    end

    # @api private
    def respond_to_missing?(name, include_all = false)
      gateways.key?(name) || super
    end

    private

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

    # Returns gateway if method is a name of a registered gateway
    #
    # @return [Gateway]
    #
    # @api private
    def method_missing(name, *)
      gateways.fetch(name) { super }
    end
  end
end
