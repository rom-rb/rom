# frozen_string_literal: true

require_relative "nestable"

module ROM
  module Registries
    # @api public
    class Schemas < Root
      prepend Nestable

      # @api private
      def define_component(**options)
        return super unless provider_type == :relation

        comp = components.get(:schemas, relation: config.component.id, abstract: false)

        comp || super(**options, relation_id: config.component.id)
      end
    end
  end
end
