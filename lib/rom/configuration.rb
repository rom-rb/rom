# frozen_string_literal: true

require "forwardable"

require "rom/support/notifications"
require "rom/environment"
require "rom/setup"
require "rom/configuration_dsl"
require "rom/support/inflector"
require "rom/relation_registry"

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

    NoDefaultAdapterError = Class.new(StandardError)

    # @!attribute [r] environment
    #   @return [Environment] Environment object with gateways
    attr_reader :environment

    # @!attribute [r] setup
    #   @return [Setup] Setup object which collects component classes and plugins
    attr_reader :setup

    # @!attribute [r] notifications
    #   @return [Notifications] Notification bus instance
    attr_reader :notifications

    # @!attribute [r] cache
    #   @return [Notifications] Cache
    attr_reader :cache

    # @!attribute [r] relations
    #   @return [ROM::RelationRegistry] relations
    attr_reader :relations

    def_delegators :@setup, :register_relation, :register_command,
                   :register_mapper, :register_plugin, :auto_register,
                   :inflector, :inflector=, :components, :plugins

    def_delegators :@environment, :gateways, :gateways_map, :configure, :config

    # Initialize a new configuration
    #
    # @see Environment#initialize
    #
    # @return [Configuration]
    #
    # @api private
    def initialize(*args, &block)
      @environment = Environment.new(*args)
      @setup = Setup.new
      @notifications = Notifications.event_bus(:configuration)
      @cache = Cache.new

      @relations = RelationRegistry.build

      block&.call(self)
    end

    # @api private
    def finalize
      setup.finalize
      self
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

    # Apply a plugin to the configuration
    #
    # @param [Mixed] plugin The plugin identifier, usually a Symbol
    # @param [Hash] options Plugin options
    #
    # @return [Configuration]
    #
    # @api public
    def use(plugin, options = {})
      if plugin.is_a?(Array)
        plugin.each { |p| use(p) }
      elsif plugin.is_a?(Hash)
        plugin.to_a.each { |p| use(*p) }
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

    # Hook for respond_to? used internally
    #
    # @api private
    def respond_to?(name, include_all = false)
      gateways.key?(name) || super
    end

    # @api private
    def default_gateway
      @default_gateway ||= gateways[:default]
    end

    # @api private
    def adapter_for_gateway(gateway)
      ROM.adapters.select do |_key, value|
        value.const_defined?(:Gateway) && gateway.is_a?(value.const_get(:Gateway))
      end.keys.first
    end

    # @api private
    def relation_classes(gateway = nil)
      classes = setup.components.relations.map(&:constant)

      return classes unless gateway

      gw_name = gateway.is_a?(Symbol) ? gateway : gateways_map[gateway]
      classes.select { |rel| rel.gateway == gw_name }
    end

    # @api private
    def default_adapter
      @default_adapter ||= adapter_for_gateway(default_gateway) || ROM.adapters.keys.first
    end

    private

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
