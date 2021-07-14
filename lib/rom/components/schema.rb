# frozen_string_literal: true

require "rom/relation/name"

require_relative "core"

module ROM
  module Components
    # @api public
    class Schema < Core
      alias_method :dataset, :id

      # @api public
      def key
        "#{namespace}.#{relation_id}"
      end

      # @api public
      def build
        if view?
          registry.schemas[dataset].instance_eval(&block)
        else
          relations = registry.relations
          inferrer = config[:inferrer].with(enabled: config[:infer])

          schema = config[:dsl_class].new(
            relation: name, **config, inferrer: inferrer, &block
          ).()

          if gateway?
            schema.finalize_attributes!(gateway: gateway, relations: relations)
          end

          schema.associations.each do |definition|
            registry.components.add(
              :associations,
              definition: definition,
              config: {
                adapter: adapter,
                namespace: "associations.#{relation_id}"
              }
            )
          end

          schema.finalize!

          schema
        end
      end

      # @api private
      def adapter
        config[:adapter]
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
