# frozen_string_literal: true

require_relative "core"

module ROM
  module Components
    # @api public
    class Association < Core
      # @!attribute [r] definition
      #   @return [Association::Definition]
      option :definition

      # @api public
      def build
        association_class.new(definition, registry.relations)
      end

      # @api public
      def id
        config.as || config.name
      end

      private

      # @api private
      def association_class
        ROM.adapters[config.adapter].const_get(:Associations).const_get(definition.type)
      end
    end
  end
end
