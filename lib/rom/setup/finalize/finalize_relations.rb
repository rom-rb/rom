require 'rom/relation_registry'

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
      def initialize(gateways, relation_classes, plugins = EMPTY_ARRAY)
        @gateways = gateways
        @relation_classes = relation_classes
        @plugins = plugins
      end

      # @return [Hash]
      #
      # @api private
      def run!
        RelationRegistry.new do |registry, relations|
          @relation_classes.each do |klass|
            relation = build_relation(klass, registry)

            key = relation.name.to_sym

            if registry.key?(key)
              raise RelationAlreadyDefinedError,
                    "Relation with `register_as #{key.inspect}` registered more " \
                    "than once"
            end

            relations[key] = relation
          end

          relations.each_value do |relation|
            relation.class.finalize(registry, relation)
          end
        end
      end

      # @return [ROM::Relation]
      #
      # @api private
      def build_relation(klass, registry)
        # TODO: raise a meaningful error here and add spec covering the case
        #       where klass' gateway points to non-existant repo
        gateway = @gateways.fetch(klass.gateway)
        ds_proc = klass.dataset_proc || -> _ { self }

        klass.schema(infer: true) unless klass.schema
        schema = klass.schema.finalize!(gateway: gateway, relations: registry)

        @plugins.each do |plugin|
          plugin.apply_to(klass)
        end

        dataset = gateway.dataset(klass.dataset, klass.dataset_options).instance_exec(klass, &ds_proc)

        options = { __registry__: registry, schema: schema.with(relations: registry), **plugin_options }

        klass.new(dataset, options)
      end

      # @api private
      def plugin_options
        @plugins.map(&:config).map(&:to_hash).reduce(:merge) || EMPTY_HASH
      end
    end
  end
end
