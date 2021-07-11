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

      defines :type

      # @api private
      def self.inherited(klass)
        super
        klass.type(Inflector.component_id(klass).to_sym)
      end

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
      option :id, type: Types::Strict::Symbol, inferrable: true

      # @!attribute [r] namespace
      #   @return [String] Registry namespace
      option :namespace, type: Types::Strict::String, inferrable: true

      # @!attribute [r] adapter
      #   @return [Class] Component's adapter
      option :adapter, type: Types::Strict::Symbol, inferrable: true

      # @!attribute [r] abstract
      #   @return [Boolean]
      option :abstract, type: Types::Strict::Bool, default: -> { false }
      alias_method :abstract?, :abstract

      # @!attribute [r] owner
      #   @return [Object] Component's owner
      option :owner, optional: true

      # @!attribute [r] provider
      #   @return [Object] Component's provider
      option :provider

      # @api public
      def type
        self.class.type
      end

      # Default container key
      #
      # @return [String]
      #
      # @api public
      memoize def key
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
        configuration.components.update(provider.components)
      end

      # @api private
      def apply_plugins
        plugins.each do |plugin|
          plugin.apply_to(constant)
        end
      end

      # @api public
      def plugins
        configuration.plugins.select { |plugin| plugin.type == type }
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
      memoize def read(name)
        # First see if the value was provided explicitly
        value =
          if option?(name)
            options[name]
          else
            provider.infer_option(name, type: type, owner: owner)
          end

        if value != Undefined
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
