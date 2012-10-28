module DataMapper
  class RelationRegistry

    class Connector
      attr_reader :name
      attr_reader :node
      attr_reader :relationship
      attr_reader :relations

      # TODO: add specs
      def initialize(name, node, relationship, relations)
        @name         = name.to_sym
        @node         = node
        @relationship = relationship
        @relations    = relations
      end

      # TODO: add specs
      def source_model
        relationship.source_model
      end

      # TODO: add specs
      def target_model
        relationship.target_model
      end

      # TODO: add specs
      def source_aliases
        relations[DataMapper[source_model].class.relation_name].aliases
      end

      # TODO: add specs
      def target_aliases
        relations[DataMapper[target_model].class.relation_name].aliases
      end

      # TODO: add specs
      def collection_target?
        relationship.collection_target?
      end

    end # class Connector

  end # class RelationRegistry
end # module DataMapper
