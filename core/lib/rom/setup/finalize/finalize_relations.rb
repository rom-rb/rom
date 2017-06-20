require 'rom/relation_registry'
require 'rom/mapper_registry'

module ROM
  class Finalize
    class FinalizeRelations
      # Build relation registry of specified descendant classes
      #
      # This is used by the setup
      #
      # @param [Hash] gateways
      # @param [Array] relation_classes a list of relation descendants
      #
      # @api private
      def initialize(gateways, relation_classes, mappers: nil, plugins: EMPTY_ARRAY)
        @gateways = gateways
        @relation_classes = relation_classes
        @mappers = mappers
        @plugins = plugins
      end

      # @return [Hash]
      #
      # @api private
      def run!
        relation_registry = RelationRegistry.new do |registry, relations|
          @relation_classes.each do |klass|
            relation = build_relation(klass, registry)

            key = relation.name.to_sym

            if registry.key?(key)
              raise RelationAlreadyDefinedError,
                    "Relation with name #{key.inspect} registered more than once"
            end

            # klass.use(:registry_reader, relation_names)

            relations[key] = relation
          end

          relations.each_value do |relation|
            relation.class.finalize(registry, relation)
          end
        end

        relation_registry.each do |_, relation|
          relation.schema.finalize_associations!(relations: relation_registry)
          relation.schema.finalize!
        end

        relation_registry
      end

      # @return [ROM::Relation]
      #
      # @api private
      def build_relation(klass, registry)
        # TODO: raise a meaningful error here and add spec covering the case
        #       where klass' gateway points to non-existant repo
        gateway = @gateways.fetch(klass.gateway)

        if klass.schema_proc && !klass.schema
          plugins = schema_plugins
          resolved_schema = klass.schema_proc.call do
            plugins.each { |plugin| app_plugin(plugin) }
          end

          klass.schema(resolved_schema)
        end

        schema = klass.schema.finalize_attributes!(gateway: gateway, relations: registry)

        relation_plugins.each do |plugin|
          plugin.apply_to(klass)
        end

        rel_key = klass.schema.name.to_sym
        dataset = gateway.dataset(klass.schema.name.dataset).instance_exec(klass, &klass.dataset)
        mappers = @mappers.key?(rel_key) ? @mappers[rel_key] : MapperRegistry.new

        options = { __registry__: registry, mappers: mappers, schema: schema, **plugin_options }

        klass.new(dataset, options)
      end

      # @api private
      def plugin_options
        relation_plugins.map(&:config).map(&:to_hash).reduce(:merge) || EMPTY_HASH
      end

      # @api private
      def relation_plugins
        @plugins.select(&:relation?)
      end

      # @api private
      def schema_plugins
        @plugins.select(&:schema?)
      end

      # @api private
      def relation_names
        @relation_classes.map(&:schema).map(&:name).map(&:relation).uniq
      end
    end
  end
end
