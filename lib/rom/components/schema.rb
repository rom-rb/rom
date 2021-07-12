# frozen_string_literal: true

require "rom/relation/name"

require_relative "core"

module ROM
  module Components
    # @api public
    class Schema < Core
      alias_method :dataset, :id

      # @api public
      def build
        if view?
          registry.schemas[dataset].instance_eval(&block)
        else
          schema = config[:dsl_class].new(relation: name, **config, &block).()
          schema.finalize_attributes!(gateway: gateway, relations: registry.relations)
          schema.finalize!
          schema
        end
      end

      # @api private
      def as
        config[:as]
      end

      # @api private
      def relation_id
        as || id
      end

      # @api private
      def name
        ROM::Relation::Name[relation_id, dataset]
      end

      # @api private
      def view?
        config[:view].equal?(true)
      end
    end
  end
end
