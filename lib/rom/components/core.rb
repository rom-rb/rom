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
      include Dry::Effects.Reader(:resolver)

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
      #   @return [Proc] Optional dataset evaluation block
      option :block, type: Types.Interface(:to_proc), optional: true

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
        resolver.trigger("configuration.#{event}", payload)
      end

      # @api public
      def notifications
        resolver.notifications
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
        plugins.each do |plugin|
          plugin.apply_to(constant)
        end
      end

      # @api public
      def plugins
        resolver.plugins.select { |plugin| plugin.type == type }
      end

      # @api public
      def plugin_options
        plugins.map(&:config).map(&:to_hash).reduce(:merge) || EMPTY_HASH
      end

      # @api public
      def gateway?
        resolver.gateways.key?(config[:gateway])
      end

      # @api public
      def gateway
        resolver.gateways[config[:gateway]]
      end
    end
  end
end
