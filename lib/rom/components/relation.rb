# frozen_string_literal: true

require_relative "core"

module ROM
  module Components
    # @api public
    class Relation < Core
      id :relation

      # @!attribute [r] name
      #   @return [Symbol] Relation name
      option :name, type: Types.Instance(ROM::Relation::Name), default: -> { default_name }

      # Registry id
      #
      # @return [Symbol]
      #
      # @api public
      def id
        options[:id] || name.relation
      end
      alias_method :relation_id, :id

      # @api private
      def default_name
        constant.default_name
      end

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
        constant.use(:registry_reader, relations: components.relations.map(&:id))

        trigger("relations.class.ready", relation: constant, adapter: adapter)

        apply_plugins

        payload = {
          schema: schema,
          adapter: adapter,
          gateway: gateway,
          relation: constant,
          registry: relations
        }

        trigger("relations.schema.set", payload)

        trigger(
          "relations.dataset.allocated",
          dataset: dataset, relation: constant, schema: schema, adapter: adapter
        )

        relation = constant.new(dataset, **relation_options)

        trigger("relations.object.registered", registry: relations, relation: relation)

        relation
      end

      private

      # @api private
      memoize def schema
        component = components.schemas(id: name.dataset).first
        component.build
      end

      # @api private
      memoize def dataset
        gateway.dataset(name.dataset).instance_exec(schema, &constant.dataset)
      end

      # @api private
      def relation_options
        {__registry__: relations,
         name: name,
         schema: schema,
         inflector: inflector,
         schemas: configuration.schemas,
         mappers: configuration.mappers.new(id, adapter: adapter),
         commands: configuration.commands.new(id, adapter: adapter),
         **plugin_options}
      end
    end
  end
end
