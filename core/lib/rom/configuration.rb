require 'forwardable'

require 'rom/environment'
require 'rom/setup'
require 'rom/configuration_dsl'

module ROM
  class Configuration
    extend Forwardable
    include ROM::ConfigurationDSL

    NoDefaultAdapterError = Class.new(StandardError)

    attr_reader :environment, :setup

    def_delegators :@setup, :register_relation, :register_command, :register_mapper, :register_plugin,
                            :relation_classes, :command_classes, :mapper_classes,
                            :auto_registration

    def_delegators :@environment, :gateways, :gateways_map, :configure, :config

    # @api public
    def initialize(*args, &block)
      @environment = Environment.new(*args)
      @setup = Setup.new

      block.call(self) unless block.nil?
    end

    # Apply a plugin to the configuration
    #
    # @param [Mixed] The plugin identifier, usually a Symbol
    # @param [Hash] Plugin options
    #
    # @api public
    def use(plugin, options = {})
      if plugin.is_a?(Array)
        plugin.each { |p| use(p) }
      elsif plugin.is_a?(Hash)
        plugin.to_a.each { |p| use(*p) }
      else
        ROM.plugin_registry.configuration.fetch(plugin).apply_to(self, options)
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

    # Returns gateway if method is a name of a registered gateway
    #
    # @return [Gateway]
    #
    # @api private
    def method_missing(name, *)
      gateways.fetch(name) { super }
    end

    # Hook for respond_to? used internally
    #
    # @api private
    def respond_to?(name, include_all=false)
      gateways.has_key?(name) || super
    end

    # @api private
    def default_gateway
      @default_gateway ||= gateways[:default]
    end

    # @api private
    def adapter_for_gateway(gateway)
      ROM.adapters.select do |key, value|
        value.const_defined?(:Gateway) && gateway.kind_of?(value.const_get(:Gateway))
      end.keys.first
    end

    # @api private
    def default_adapter
      @default_adapter ||= adapter_for_gateway(default_gateway) || ROM.adapters.keys.first
    end
  end
end
