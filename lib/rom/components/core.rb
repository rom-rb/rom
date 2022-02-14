# frozen_string_literal: true

require "dry/effects"
require "dry/core/class_attributes"
require "dry/core/memoizable"

require "rom/constants"
require "rom/initializer"
require "rom/types"

module ROM
  module Components
    # Abstract component class
    #
    # @api public
    class Core
      include Dry::Effects.Reader(:registry)

      extend Initializer
      extend Dry::Core::ClassAttributes

      include Dry::Core::Memoizable

      defines :type

      # @api private
      def self.inherited(klass)
        super
        klass.type(Inflector.component_id(klass).to_sym)
      end

      # @!attribute [r] provider
      #   @return [Object] Component's provider
      option :provider

      # @!attribute [r] config
      #   @return [Object] Component's config
      option :config, type: Types.Instance(Dry::Configurable::Config)

      # @!attribute [r] gateway
      #   @return [Proc] Optional component evaluation block
      option :block, type: Types.Interface(:to_proc), optional: true

      # @api public
      def type
        self.class.type
      end

      # @api public
      def abstract
        config.abstract
      end
      alias_method :abstract?, :abstract

      # Default container key
      #
      # @return [String]
      #
      # @api public
      memoize def key
        "#{namespace}.#{id}"
      end

      # @api public
      def id
        config.id
      end

      # @api public
      def namespace
        config.namespace
      end

      # This method is meant to return a run-time component instance
      #
      # @api public
      def build(**)
        raise NotImplementedError
      end

      # @api public
      def trigger(event, payload)
        registry.trigger("configuration.#{event}", payload)
      end

      # @api public
      def notifications
        registry.notifications
      end

      # @api public
      def inflector
        config.inflector
      end

      # @api private
      def components
        provider.components
      end

      # @api private
      def local_components
        EMPTY_ARRAY
      end

      # @api private
      def apply_plugins
        applied = plugins.reject(&:applied?).map do |plugin|
          plugin.enable(constant) unless plugin.enabled?
          plugin.apply unless plugin.applied?
          plugin.name
        end

        # This is unfortunate, but it was possible to enable plugins for a component
        # type *AFTER* components have been created, this keeps this behavior
        provider_plugins
          .reject { |plugin| applied.include?(plugin.name) }
          .each { |plugin|
            plugin.enable(constant) unless plugin.enabled?
            plugin.apply unless plugin.applied?
            config.plugins << plugin
          }
      end

      # @api private
      def plugins
        config.plugins.select { |plugin| plugin.type == type }
      end

      # @api private
      def provider_plugins
        provider.config.component.plugins.select { |plugin| plugin.type == type }
      end

      # @api public
      def plugin_options
        plugins.map(&:config).map(&:to_hash).reduce(:merge) || EMPTY_HASH
      end

      # @api public
      def gateway?
        registry.gateways.key?(config[:gateway])
      end

      # @api public
      def gateway
        registry.gateways[config[:gateway]]
      end
    end
  end
end
