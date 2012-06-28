module DataMapper
  class Mapper

    # VeritasMapper
    #
    # @api public
    class VeritasMapper < Mapper

      # @api public
      def self.one(conditions = {})
        find(conditions).first
      end

      # @api public
      def self.find(conditions = {})
        relation = DataMapper[model].relation

        conditions.each do |attribute, value|
          relation = relation.restrict do |r|
            field = attributes[attribute].field
            r.send(field).eq(value)
          end
        end

        new(relation)
      end

      # @api public
      def self.one(conditions = {})
        relation = DataMapper[model].relation

        conditions.each do |attribute, value|
          relation = relation.restrict do |r|
            field = attributes[attribute].field
            r.send(field).eq(value)
          end
        end

        new(relation).first
      end

      # @api public
      def self.base_relation
        @base_relation ||= Veritas::Relation::Base.new(
          relation_name, attributes.header)
      end

      # @api private
      attr_reader :relation

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
      def include(name)
        self.class.new(@relationships[name].join(@relation))
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
        @model.new(
          @attributes.load(tuple).merge(@relationships.load(tuple)))
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
