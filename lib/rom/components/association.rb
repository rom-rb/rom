# frozen_string_literal: true

require_relative "core"

module ROM
  module Components
    # @api public
    class Association < Core
      option :definition

      # @api public
      memoize def id
        definition.aliased? ? definition.as : definition.name
      end

      # @api public
      def name
        definition.name
      end

      # @api public
      def as
        definition.as
      end

      # @api public
      def build
        association_class.new(definition, registry.relations)
      end

      private

      # @api private
      def association_class
        ROM.adapters[adapter].const_get(:Associations).const_get(definition.type)
      end

      # @api private
      def adapter
        config[:adapter]
      end
    end
  end
end
