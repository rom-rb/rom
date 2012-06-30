module DataMapper
  class Mapper

    # VeritasMapper
    #
    # @api public
    class VeritasMapper < Mapper
      TAUTOLOGY = Veritas::Function::Proposition::Tautology.instance

      # @api public
      def self.base_relation
        @base_relation ||= Veritas::Relation::Base.new(
          relation_name, attributes.header)
      end

      # @api private
      attr_reader :relation, :attributes

      # Initialize a veritas mapper instance
      #
      # @param [Veritas::Relation]
      #
      # @return [undefined]
      #
      # @api public
      def initialize(relation)
        @relation      = relation
        @attributes    = self.class.attributes
        @relationships = self.class.relationships
        @model         = self.class.model
      end

      # @api public
      def each
        return to_enum unless block_given?
        @relation.each { |tuple| yield load(tuple) }
        self
      end

      # @api public
      def find(options)
        query = options.dup
        order = query.delete(:order)

        restriction = relation.restrict do |r|
          query.inject(TAUTOLOGY) do |predicate, (attribute, value)|
            predicate.and(r.send(@attributes.field_name(attribute)).eq(value))
          end
        end

        if order
          restriction = restriction.sort_by do |r|
            # TODO: automatically fill in missing attributes as veritas requires
            #       all attributes from the header
            order.map { |attribute| r.send(@attributes.field_name(attribute)) }
          end
        end

        self.class.new(restriction.optimize)
      end

      # @api public
      def one(options = {})
        results = find(options).to_a

        if results.size == 1
          results.first
        else
          # TODO: add custom error class
          raise "#{self}.one returned more than one result"
        end
      end

      # @api public
      def include(name)
        @relationships[name].mapper(@relation)
      end

      # @api public
      def restrict(&block)
        self.class.new(@relation.restrict(&block))
      end

      # @api public
      def sort_by(&block)
        self.class.new(@relation.sort_by(&block))
      end

      # @api private
      def load(tuple)
        @model.new(@attributes.load(tuple))
      end

      # @api public
      def dump(object)
        @attributes.each_with_object({}) do |attribute, attributes|
          attributes[attribute.field] = object.send(attribute.name)
        end
      end

    end # class VeritasMapper
  end # class Mapper
end # module DataMapper
