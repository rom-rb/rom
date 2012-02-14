module DataMapper
  class Mapper

    # VeritasMapper
    #
    # @api public
    class VeritasMapper < Mapper

      # @api public
      attr_reader :relation

      # @api public
      def self.find(query=nil)
        mapper = new(gateway(base_relation))

        if query
          mapper.find(query)
        else
          mapper
        end
      end

      # @api private
      def self.gateway(relation)
        Veritas::Relation::Gateway.new(DATABASE_ADAPTER, relation)
      end

      # @api private
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
        @relation = relation || self.class.base_relation
      end

      # @api public
      def find(conditions)
        conditions.each do |key, value|
          @relation = relation.restrict do |r|
            r.send(self.class.attributes[key].map_to).eq(value)
          end
        end
        self
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
