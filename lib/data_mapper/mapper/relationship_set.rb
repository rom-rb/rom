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
      def finalize
        each { |relationship| relationship.finalize }
      end

      # @api public
      def add_through(source, name, &operation)
        self << self[source].inherit(name, operation)
      end

      # @api private
      def add(name, options)
        @relationships[name] = options.type.new(options)
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

    end # class RelationshipSet
  end # class Mapper
end # module DataMapper
