module DataMapper
  class Mapper

    # VeritasMapper
    #
    # @api public
    class VeritasMapper < Mapper

      # @api public
      attr_reader :relation

      # @api public
      def self.base_relation
        @base_relation ||= Veritas::Relation::Base.new(name, attributes.header)
      end

      # Initialize a veritas mapper instance
      #
      # @param [Veritas::Relation]
      #
      # @return [undefined]
      #
      # @api public
      def initialize(relation)
        @relation = relation
      end

      # @api public
      def each
        return to_enum unless block_given?
        relation.each { |tuple| yield load(tuple) }
        self
      end

      # @api private
      def load(tuple)
        model.new(attributes.map(tuple))
      end

    private

      # @api private
      def attributes
        self.class.attributes
      end

      # @api private
      def model
        self.class.model
      end

    end # class VeritasMapper
  end # class Mapper
end # module DataMapper
