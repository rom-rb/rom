module DataMapper
  class RelationRegistry

    class Connector
      attr_reader :name
      attr_reader :node
      attr_reader :relationship
      attr_reader :relations

      def initialize(name, node, relationship, relations)
        @name         = name.to_sym
        @node         = node
        @relationship = relationship
        @relations    = relations
      end

      def source_model
        relationship.source_model
      end

      def target_model
        relationship.target_model
      end

      def source_aliases
        relations[DataMapper[source_model].class.relation_name].aliases
      end

      def target_aliases
        relations[DataMapper[target_model].class.relation_name].aliases
      end

      def collection_target?
        relationship.collection_target?
      end

    end # class Connector

  end # class RelationRegistry
end # module DataMapper
