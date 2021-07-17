# frozen_string_literal: true

require_relative "core"

module ROM
  module Components
    # @api public
    class Relation < Core
      # @!attribute [r] constant
      #   @return [.new] Relation instance builder (typically a class)
      option :constant, type: Types.Interface(:new)

      # @return [ROM::Relation]
      #
      # @api public
      def build
        constant.use(:registry_reader, relations: resolver.relation_ids)

        trigger("relations.class.ready", relation: constant, adapter: adapter)

        apply_plugins

        relation = constant.new(inflector: inflector, resolver: resolver, **plugin_options)

        trigger(
          "relations.schema.set",
          schema: relation.schema,
          adapter: adapter,
          gateway: config[:gateway],
          relation: constant,
          resolver: resolver
        )

        trigger("relations.object.registered", resolver: resolver, relation: relation)

        relation
      end

      # @api public
      def adapter
        config.adapter
      end

      # @api private
      def local_components
        constant.components
      end
    end
  end
end
