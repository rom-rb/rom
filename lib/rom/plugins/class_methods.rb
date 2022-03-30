# frozen_string_literal: true

module ROM
  module Plugins
    # @api public
    module ClassMethods
      # Include a registered plugin in this relation class
      #
      # @param [Symbol] plugin
      # @param [Hash] options
      # @option options [Symbol] :adapter (:default) first adapter to check for plugin
      #
      # @api public
      def use(name, **options)
        plugin = plugins[name].configure(**options).enable(self).apply
        component_config.plugins << plugin
        self
      end

      # Return all available plugins for the component type
      #
      # @api public
      def plugins
        @plugins ||= ROM.plugins[component_config.type].adapter(component_config.adapter)
      end

      private

      # Return component configuration
      #
      # @api private
      def component_config
        @component_config ||= config.key?(:component) ? config.component : config
      end
    end
  end
end
