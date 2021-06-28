# frozen_string_literal: true

require_relative "core"

module ROM
  module Components
    # @api public
    class Relation < Core
      id :relation

      # Registry id
      #
      # @return [Symbol]
      #
      # @api public
      def id
        # TODO: this could go away already
        options[:id] || constant.relation_name.to_sym
      end
      alias_method :relation_id, :id

      # Registry namespace
      #
      # @return [String]
      #
      # @api public
      def namespace
        "relations"
      end

      # @return [ROM::Relation]
      #
      # @api public
      def build
        # TODO: this should become a built-in feature, no neeed to use a plugin
        constant.use(:registry_reader, relations: components.relations.map(&:id).uniq)

        trigger("relations.class.ready", relation: constant, adapter: adapter)

        # schema must be established prior applying plugins because they may
        # depend on the schema
        schema = finalize_schema

        apply_plugins

        trigger("relations.dataset.allocated", dataset: dataset, relation: constant,
                                               adapter: adapter)

        relation = constant.new(dataset, **relation_options(schema))

        trigger("relations.object.registered", registry: relations, relation: relation)

        relation
      end

      private

      # @api private
      memoize def dataset
        gateway.dataset(constant.relation_name.dataset).instance_exec(constant, &constant.dataset)
      end

      # @api private
      def relation_options(schema)
        {__registry__: relations,
         schema: schema,
         inflector: inflector,
         mappers: configuration.mappers.new(id, adapter: adapter),
         commands: configuration.commands.new(id, adapter: adapter),
         **plugin_options}
      end

      # @api private
      def finalize_schema
        # TODO: relation DSL auto-defines an empty schema so this is a workaround
        components.schemas(relation: constant).last.build
      end
    end
  end
end
