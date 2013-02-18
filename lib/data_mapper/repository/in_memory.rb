module DataMapper
  class Repository

    # A repository backed by in memory relations
    #
    # @api private
    class InMemory < self
      private

      # Build veritas in memory relation
      #
      # @param [Symbol] name
      #   the relation name
      #
      # @param [Veritas::Relation::Header] header
      #
      # @return [Veritas::Relation]
      #
      # @api private
      #
      def build(_name, header)
        Veritas::Relation.new(header, [])
      end
    end # class InMemory
  end # class Repository
end # module DataMapper
