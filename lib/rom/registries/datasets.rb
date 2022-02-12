# frozen_string_literal: true

require_relative "nestable"

module ROM
  module Registries
    # @api public
    class Datasets < Root
      prepend Nestable

      # @api private
      def define_component(**options)
        return super unless provider_type == :relation

        comp = components.get(:datasets, relation_id: config.component.id, abstract: false)

        comp || super(**options, id: config.component.dataset, relation_id: config.component.id)
      end
    end
  end
end
