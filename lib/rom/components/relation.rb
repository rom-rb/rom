# frozen_string_literal: true

require_relative "core"

module ROM
  module Components
    # @api public
    class Relation < Core
      id :relation

      # @!attribute [r] key
      #   @return [Symbol] The relation identifier
      #   @api public
      option :key, type: Types.Instance(Symbol), default: -> {
        # TODO: another workaround for auto_register specs not using actual rom classes
        constant.respond_to?(:relation_name) ? constant.relation_name.to_sym : constant.name.to_sym
      }
      alias_method :id, :key

      # @api public
      def adapter
        constant.adapter
      end

      # @return [ROM::Relation]
      #
      # @api public
      def build
        unless adapter
          raise MissingAdapterIdentifierError,
                "Relation class +#{constant}+ is missing the adapter identifier"
        end

        relation_names = components.relations.map(&:key)

        # TODO: this should become a built-in feature, no neeed to use a plugin
        constant.use(:registry_reader, relations: relation_names)

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
        components.schemas
          .select { |schema| schema.relation == constant }
          .last # TODO: relation DSL auto-defines an empty schema so this is a workaround
          .build
      end

      # @api private
      def finalize_mappers
        mappers = components[:mappers]
          .map { |mapper| [mapper.key, mapper.build] if mapper.base_relation == key }
          .compact
          .to_h

        constant.mapper_registry(cache: configuration.cache).merge(mappers)
      end

      # @api private
      def finalize_commands(relation)
        commands = components.commands
          .select { |command| command.relation_name == constant.relation_name.relation }
          .map { |command| command.build(relation: relation) }

        commands.each do |command|
          identifier = command.class.register_as || command.class.default_name
          relation.commands.elements[identifier] = command
        end

        command_compiler.commands.elements[constant.relation_name.relation] = relation.commands

        relation.commands.set_compiler(command_compiler)
        relation.commands.set_mappers(relation.mappers)
      end
    end
  end
end
