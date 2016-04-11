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
      def initialize(gateways, relation_classes)
        @gateways = gateways
        @relation_classes = relation_classes
      end

      # @return [Hash]
      #
      # @api private
      def run!
        registry = {}

        @relation_classes.each do |klass|
          # TODO: raise a meaningful error here and add spec covering the case
          #       where klass' gateway points to non-existant repo
          gateway = @gateways.fetch(klass.gateway)
          ds_proc = klass.dataset_proc || -> _ { self }
          dataset = gateway.dataset(klass.dataset).instance_exec(klass, &ds_proc)

          relation = klass.new(dataset, __registry__: registry)

          name = klass.register_as

          if registry.key?(name)
            raise RelationAlreadyDefinedError,
              "Relation with `register_as #{name.inspect}` registered more " \
              "than once"
          end

          registry[name] = relation
        end

        registry.each_value do |relation|
          relation.class.finalize(registry, relation)
        end

        RelationRegistry.new(registry)
      end
    end
  end
end
