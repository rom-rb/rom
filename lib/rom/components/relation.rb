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
      memoize def build
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

        relation = constant.new(**relation_options)

        trigger("relations.object.registered", registry: relations, relation: relation)

        relation
      end

      private

      # @api private
      def schema
        configuration.schemas[name.dataset]
      end

      # @api private
      def relation_options
        {__registry__: relations,
         name: name,
         schema: schema,
         inflector: inflector,
         datasets: configuration.datasets,
         schemas: configuration.schemas,
         associations: configuration.associations.new(id, items: schema.associations),
         mappers: configuration.mappers.new(id, adapter: adapter),
         commands: configuration.commands.new(id, adapter: adapter),
         **plugin_options}
      end
    end
  end
end
