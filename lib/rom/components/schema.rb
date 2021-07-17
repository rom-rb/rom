# frozen_string_literal: true

require "rom/relation/name"

require_relative "core"

module ROM
  module Components
    # @api public
    class Schema < Core
      # @api public
      def build
        if view?
          resolver.schemas[relation].instance_eval(&block)
        else
          relations = resolver.relations
          inferrer = config.inferrer.with(enabled: config.infer)

          schema = config.dsl_class.new(
            **config, relation: name, plugins: plugins, inferrer: inferrer, &block
          ).()

          if gateway?
            schema.finalize_attributes!(gateway: gateway, relations: relations)
          else
            schema.finalize_attributes!(relations: relations)
          end

          # TODO: schemas should no longer create associations
          schema.associations.each do |definition|
            components.add(
              :associations,
              definition: definition,
              config: assoc_config.inherit(definition.options)
            )
          end

          schema.finalize!

          schema
        end
      end

      # @api public
      def key
        root = "#{namespace}.#{relation}"

        if view?
          "#{root}.#{id}"
        else
          root
        end
      end

      # @api private
      memoize def assoc_config
        provider.config.association.update(adapter: adapter, namespace: "associations.#{relation}")
      end

      # TODO: schema's should not depend on Name objects
      #
      # @api private
      def name
        ROM::Relation::Name[relation, id]
      end

      # @api private
      def adapter
        config.adapter
      end

      # @api private
      def as
        config.as
      end

      # @api private
      def relation
        config.relation
      end

      # @api private
      def view?
        config.view.equal?(true)
      end
    end
  end
end
