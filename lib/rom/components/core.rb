# frozen_string_literal: true

require "dry/effects"
require "dry/core/class_attributes"
require "dry/core/memoizable"

require "rom/constants"
require "rom/initializer"
require "rom/types"

require_relative "resolver"

module ROM
  module Components
    # Abstract component class
    #
    # @api public
    class Core
      extend Initializer
      extend Dry::Core::ClassAttributes

      include Dry::Core::Memoizable
      include Dry::Effects.Reader(:configuration)

      defines :id

      # @api private
      def self.option(name, **options)
        if options[:inferrable]
          super(name, reader: false, optional: true, **options)
          define_method(name) { read(name) }
        else
          super
        end
      end

      # @!attribute [r] id
      #   @return [Symbol] Local registry id
      option :id, inferrable: true, type: Types::Strict::Symbol

      # @!attribute [r] namespace
      #   @return [String] Registry namespace
      option :namespace, optional: true, reader: false, type: Types::Strict::String

      # @!attribute [r] owner
      #   @return [Object] Component's owner
      option :owner

      # @!attribute [r] provider
      #   @return [Object] Component's original provider
      option :provider, optional: true

      # @!attribute [r] adapter
      #   @return [Class] Component's adapter
      option :adapter, inferrable: true, type: Types::Strict::Symbol

      # @api public
      def type
        self.class.id
      end

      # Default container key
      #
      # @return [String]
      #
      # @api public
      def key
        "#{namespace}.#{id}"
      end

      # This method is meant to return a run-time component instance
      #
      # @api public
      def build(**)
        raise NotImplementedError
      end

      # @api public
      def trigger(event, payload)
        notifications.trigger("configuration.#{event}", payload)
      end

      # @api public
      def relations
        configuration.relations
      end

      # @api public
      def mapper_registry
        configuration.mapper_registry
      end

      # @api public
      def inflector
        configuration.inflector
      end

      # @api public
      def cache
        configuration.cache
      end

      # @api public
      def command_compiler
        configuration.command_compiler
      end

      # @api public
      def notifications
        configuration.notifications
      end

      # @api public
      def gateways
        configuration.gateways
      end

      # @api public
      memoize def components
        configuration.components.update(local_components)
      end

      # @api public
      memoize def local_components
        registry = Components::Registry.new(owner: owner)

        if provider != configuration && provider.respond_to?(:components)
          registry.update(provider.components)
        end

        if respond_to?(:constant) && constant.respond_to?(:components)
          registry.update(constant.components)
        end

        registry
      end

      # @api private
      def apply_plugins
        plugins.each do |plugin|
          plugin.apply_to(constant)
        end
      end

      # @api public
      def plugins
        configuration.plugins.select { |plugin| plugin.type == self.class.id }
      end

      # @api public
      def plugin_options
        plugins.map(&:config).map(&:to_hash).reduce(:merge) || EMPTY_HASH
      end

      # @api private
      def option?(name)
        !options[name].nil?
      end

      # @api private
      memoize def provider_config
        provider.respond_to?(:config) ? provider.config.to_h : EMPTY_HASH
      end

      # @api private
      memoize def read(name)
        # First see if the value was provided explicitly
        value = options[name]

        # Then try to read it from the provider's configuration
        value ||= provider_config[type]&.fetch(name) { provider_config[name] }

        # If the value is a proc, call it by passing the provider - this makes it
        # possible to have a fallback mechanism implemented in a parent class.
        # ie Relation can fallback to its class attributes that are deprecated now.
        # This means `Relation.schema_class` can be the fallback for config.schema.constant
        evaled = value.is_a?(Proc) ? value.(provider) : value

        # Last resort - delegate inference to the provider itself
        value = evaled || owner.infer_option(name, component: self)

        if value
          options[name] = instance_variable_set(:"@#{name}", value)
        else
          raise ConfigError.new(name, self, :inferrence)
        end

        value
      end

      # @api public
      def gateway?
        # TODO: this needs to be encapsulated
        configuration.config.gateways.key?(gateway)
      end

      private

      # @api private
      def _gateway
        gateways.fetch(gateway) do
          raise "+#{gateway.inspect}+ gateway not found for #{constant}"
        end
      end
    end
  end
end
