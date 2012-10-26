module DataMapper
  class RelationRegistry

    class Connector
      attr_reader :name
      attr_reader :relation
      attr_reader :relationship

      def initialize(name, relation, relationship)
        @name         = name
        @relation     = relation
        @relationship = relationship
      end

    end # class Connector

  end # class RelationRegistry
end # module DataMapper
