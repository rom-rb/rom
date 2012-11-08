module DataMapper
  class Mapper

    # RelationshipSet scoped to a single {Mapper}
    #
    # Since set uniqueness is based on {Relationship#name}
    # it is not safe to store relationships from more than
    # one {Mapper} in instances of this class.
    #
    # @api private
    class RelationshipSet
      include Enumerable

      # @api private
      def initialize(entries = nil)
        @entries = {}
        merge(entries || [])
      end

      # @api private
      def each
        return to_enum unless block_given?
        @entries.each_value { |entry| yield(entry) }
        self
      end

      # @api private
      def <<(entry)
        @entries[entry.name] = entry
        self
      end

      # @api private
      def [](name)
        @entries[name]
      end

      # @api private
      def size
        @entries.size
      end

      def find_dependent(model)
        direct_targets     = direct_targets(model)
        transitive_targets = transitive_targets(direct_targets)

        self.class.new(direct_targets.concat(transitive_targets))
      end

      private

      # @api private
      def direct_targets(model)
        select { |entry| entry.target_model.equal?(model) }
      end

      # @api private
      def transitive_targets(relationships)
        select { |entry| relationships.include?(self[entry.via]) }
      end

      # @api private
      def merge(other)
        other.each { |entry| self << entry }
        self
      end
    end # class RelationshipSet
  end # class Mapper
end # module DataMapper
