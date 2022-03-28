# frozen_string_literal: true

require_relative "nestable"

module ROM
  module Registries
    # @api public
    class Schemas < Root
      prepend Nestable

      # Resolve relation's canonical schema
      #
      # @param provider [#config]
      # @return [Schema]
      #
      # @api public
      def canonical(provider)
        schema = scoped(provider.config.component.id).fetch(provider.config.component.dataset) {
          fetch(provider.config.component.id)
        }

        if schema.is_a?(self.class)
          unscoped.fetch(provider.config.component.id)
        else
          schema
        end
      end

      # @api private
      def unscoped
        root.schemas
      end

      # @api private
      def define_component(**options)
        return super unless provider_type == :relation

        comp = components.get(:schemas, relation: config.component.id, abstract: false)

        comp || super(**options, relation_id: config.component.id)
      end
    end
  end
end
