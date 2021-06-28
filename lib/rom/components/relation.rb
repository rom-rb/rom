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
        constant.relation_name.to_sym
      end

      # Default container key
      #
      # @return [String]
      #
      # @api public
      def key
        "relations.#{id}"
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

        constant.new(dataset, **relation_options(schema))
      end

      private

      # @api private
      memoize def dataset
        gateway.dataset(constant.relation_name.dataset).instance_exec(constant, &constant.dataset)
      end

      # TODO: this will be removed once mapper registry is lazy-by-default
      #
      # @api private
      memoize def mappers
        registry = constant.mapper_registry(cache: configuration.cache)

        components.mappers(relation_id: id).each do |component|
          registry.add(component.id, &component)
        end

        registry
      end

      # @api private
      def relation_options(schema)
        {__registry__: relations,
         mappers: mappers,
         commands: commands(mappers), # TODO: passing mappers shouldn't be needed
         schema: schema,
         inflector: configuration.inflector,
         **plugin_options}
      end

      # @api private
      def finalize_schema
        # TODO: relation DSL auto-defines an empty schema so this is a workaround
        components.schemas(relation: constant).last.build
      end

      # TODO: this will be removed once command registry is lazy-by-default
      #
      # @api private
      def commands(mappers)
        registry = constant.command_registry(
          relation_name: id,
          cache: configuration.cache,
          compiler: command_compiler,
          mappers: mappers
        )

        command_compiler.commands.elements[id] = registry

        components.commands(relation_id: id).each do |component|
          registry.add(component.id, &component)
        end

        registry
      end
    end
  end
end
