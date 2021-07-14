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
        root = "#{namespace}.#{relation_id}"

        if view?
          "#{root}.#{id}"
        else
          root
        end
      end

      # @api public
      def build
        if view?
          registry.schemas[relation_id].instance_eval(&block)
        else
          relations = registry.relations
          inferrer = config[:inferrer].with(enabled: config[:infer])

          schema = config[:dsl_class].new(
            relation: name, plugins: plugins, **config, inferrer: inferrer, &block
          ).()

          if gateway?
            schema.finalize_attributes!(gateway: gateway, relations: relations)
          else
            schema.finalize_attributes!(relations: relations)
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
        config.fetch(:relation_id) { as || id }
      end

      # @api private
      def name
        ROM::Relation::Name[relation_id, id]
      end

      # @api private
      def view?
        view.equal?(true)
      end

      # @api private
      def view
        config[:view]
      end
    end
  end
end
