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

        schema = finalize_schema

        apply_plugins

        dataset = gateway.dataset(schema.name.dataset).instance_exec(constant, &constant.dataset)

        trigger("relations.dataset.allocated", dataset: dataset, relation: constant, adapter: adapter)

        # TODO: this will be removed once mapper registry is lazy-by-default
        mappers = finalize_mappers

        options = {
          __registry__: relations,
          mappers: mappers,
          schema: schema,
          inflector: configuration.inflector,
          **plugin_options
        }

        relation = constant.new(dataset, **options)

        # TODO: this will be removed once command registry is lazy-by-default
        finalize_commands(relation)

        relation
      end

      private

      # @api private
      def finalize_schema
        # TODO: relation DSL auto-defines an empty schema so this is a workaround
        components.schemas(relation: constant).last.build
      end

      # @api private
      def finalize_mappers
        mappers = components.mappers(relation_id: id)

        registry = constant.mapper_registry(cache: configuration.cache)

        mappers.each do |mapper|
          registry.add(mapper.id, mapper.build)
        end

        registry
      end

      # @api private
      def finalize_commands(relation)
        commands = components.commands(relation_id: id)

        commands.each do |command|
          relation.commands.add(command.id, command.build(relation: relation))
        end

        command_compiler.commands.elements[constant.relation_name.relation] = relation.commands

        relation.commands.set_compiler(command_compiler)
        relation.commands.set_mappers(relation.mappers)
      end
    end
  end
end
