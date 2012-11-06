module DataMapper
  class Mapper

    # RelationshipSet
    #
    # @api private
    class RelationshipSet
      include Enumerable

      # @api private
      def initialize(relationships = {})
        @relationships = relationships
      end

      # @api public
      def each
        return to_enum unless block_given?
        @relationships.each_value { |relationship| yield relationship }
        self
      end

      # @api public
      def <<(relationship)
        @relationships[relationship.name] = relationship
        self
      end

      # @api private
      def [](name)
        @relationships[name]
      end

      # @api private
      def for_target(model)
        select { |relationship| relationship.target_model.equal?(model) }
      end

      # @api private
      def find_dependent(relationships)
        via_names = relationships.map(&:name)
        select { |relationship| via_names.include?(relationship.via) }
      end

    end # class RelationshipSet
  end # class Mapper
end # module DataMapper
