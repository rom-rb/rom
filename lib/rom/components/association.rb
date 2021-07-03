# frozen_string_literal: true

require_relative "core"

module ROM
  module Components
    # @api public
    class Association < Core
      id :association

      option :object
      alias_method :definition, :object

      # Registry namespace
      #
      # @return [String]
      #
      # @api public
      def namespace
        options[:namespace]
      end

      # @api public
      def id
        definition.aliased? ? definition.as : definition.name
      end

      # @api public
      memoize def build
        association_class.new(definition, relations)
      end

      private

      # @api private
      def association_class
        adapter_namespace.const_get(:Associations).const_get(definition.type)
      end

      # @api private
      def adapter_namespace
        ROM.adapters[gateway.config.adapter]
      end

      # @api private
      def gateway_name
        # TODO: there's a nicer way to do that by actually passing gateway as an option
        components.relations(id: definition.source.to_sym).first.constant.gateway
      end
    end
  end
end
