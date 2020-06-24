# frozen_string_literal: true

require "rom/constants"
require "rom/relation_registry"
require "rom/mapper_registry"
require "rom/support/inflector"

module ROM
  class Finalize
    class FinalizeRelations
      attr_reader :notifications

      attr_reader :inflector

      # Build relation registry of specified descendant classes
      #
      # This is used by the setup
      #
      # @param [Hash] gateways
      # @param [Array] relation_classes a list of relation descendants
      #
      # @api private
      def initialize(gateways, relation_classes, **options)
        @gateways = gateways
        @relation_classes = relation_classes
        @inflector = options.fetch(:inflector, Inflector)
        @mappers = options.fetch(:mappers, nil)
        @plugins = options.fetch(:plugins, EMPTY_ARRAY)
        @notifications = options.fetch(:notifications)
      end

      # @return [Hash]
      #
      # @api private
      def run!
        relation_registry = RelationRegistry.new do |registry, relations|
          @relation_classes.each do |klass|
            unless klass.adapter
              raise MissingAdapterIdentifierError,
                    "Relation class +#{klass}+ is missing the adapter identifier"
            end

            key = klass.relation_name.to_sym

            if registry.key?(key)
              raise RelationAlreadyDefinedError,
                    "Relation with name #{key.inspect} registered more than once"
            end

            klass.use(:registry_reader, relations: relation_names)

            notifications.trigger("configuration.relations.class.ready", relation: klass, adapter: klass.adapter)

            relations[key] = build_relation(klass, registry)
          end

          registry.each do |_, relation|
            notifications.trigger(
              "configuration.relations.object.registered",
              relation: relation, registry: registry
            )
          end
        end

        notifications.trigger(
          "configuration.relations.registry.created", registry: relation_registry
        )

        relation_registry
      end

      # @return [ROM::Relation]
      #
      # @api private
      def build_relation(klass, registry)
        # TODO: raise a meaningful error here and add spec covering the case
        #       where klass' gateway points to non-existant repo
        gateway = @gateways.fetch(klass.gateway)

        plugins = schema_plugins

        schema = klass.schema_proc.call do
          plugins.each { |plugin| app_plugin(plugin) }
        end

        klass.set_schema!(schema) if klass.schema.nil?

        notifications.trigger(
          "configuration.relations.schema.allocated",
          schema: schema, gateway: gateway, registry: registry
        )

        relation_plugins.each do |plugin|
          plugin.apply_to(klass)
        end

        notifications.trigger(
          "configuration.relations.schema.set",
          schema: schema, relation: klass, registry: registry, adapter: klass.adapter
        )

        rel_key = schema.name.to_sym
        dataset = gateway.dataset(schema.name.dataset).instance_exec(klass, &klass.dataset)

        notifications.trigger(
          "configuration.relations.dataset.allocated",
          dataset: dataset, relation: klass, adapter: klass.adapter
        )

        options = {
          __registry__: registry,
          mappers: mapper_registry(rel_key, klass),
          schema: schema,
          inflector: inflector,
          **plugin_options
        }

        klass.new(dataset, **options)
      end

      # @api private
      def mapper_registry(rel_key, rel_class)
        registry = rel_class.mapper_registry(cache: @mappers.cache)

        if @mappers.key?(rel_key)
          registry.merge(@mappers[rel_key])
        else
          registry
        end
      end

      # @api private
      def plugin_options
        relation_plugins.map(&:config).map(&:to_hash).reduce(:merge) || EMPTY_HASH
      end

      # @api private
      def relation_plugins
        @plugins.select { |p| p.type == :relation }
      end

      # @api private
      def schema_plugins
        @plugins.select { |p| p.type == :schema }
      end

      # @api private
      def relation_names
        @relation_classes.map(&:relation_name).map(&:relation).uniq
      end
    end
  end
end
