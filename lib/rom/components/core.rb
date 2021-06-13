# frozen_string_literal: true

require "dry/effects"
require "dry/core/class_attributes"

require "rom/constants"
require "rom/initializer"
require "rom/types"

module ROM
  module Components
    # Abstract component class
    #
    # @api public
    class Core
      extend Initializer
      extend Dry::Core::ClassAttributes

      include Dry::Effects.Reader(:configuration)

      defines :id

      # @!attribute [r] constant
      #   @return [Class] Component's target class
      #   @api public
      option :constant, optional: true, type: Types.Interface(:new)
      alias_method :relation, :constant

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
      def components
        configuration.components
      end

      # @api public
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

      private

      # @api private
      def gateway
        gateways.fetch(relation.gateway) do
          raise "+#{constant}+ gateway not found #{constant.gateway.inspect}"
        end
      end
    end
  end
end
