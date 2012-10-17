module DataMapper
  class Mapper

    # Relation
    #
    # @api public
    class Relation < self
      alias_method :all, :to_a

      attr_reader :relationships

      def self.from(other, name = nil)
        klass = super
        klass.repository(other.repository)
        klass
      end

      # Set or return the name of this mapper's default repository
      #
      # @api public
      def self.repository(name = Undefined)
        if name.equal?(Undefined)
          @repository
        else
          @repository = name
        end
      end

      def self.relation
        @relation ||= Veritas::Relation::Empty.new(attributes.header)
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
      def initialize(relation = self.class.relation, attributes = self.class.attributes)
        @relation      = relation
        @attributes    = attributes
        @relationships = self.class.relationships
        @model         = self.class.model
      end

      # TODO find a better name
      def remap(aliases)
        self.class.new(@relation, @attributes.remap(aliases))
      end

      # @api public
      def each
        return to_enum unless block_given?
        @relation.each { |tuple| yield load(tuple) }
        self
      end

      # @api public
      def inspect
        "<##{self.class.name}:#{object_id} @model=#{@model} @repository=#{self.class.repository} @relation=#{@relation}>"
      end

      # @api public
      def find(options)
        restriction = @relation.restrict(Query.new(options, @attributes))
        self.class.new(restriction)
      end

      # @api public
      def order(*order)
        attributes = order.map { |attribute|
          @attributes.field_name(attribute)
        }

        attributes = attributes.concat(@attributes.fields).uniq

        sorted = relation.sort_by { |r|
          attributes.map { |attribute| r.send(attribute) }
        }

        self.class.new(sorted)
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
        Mapper.mapper_registry[self.class.model, @relationships[name]]
      end

      # @api public
      def restrict(&block)
        self.class.new(@relation.restrict(&block))
      end

      # @api public
      def sort_by(&block)
        self.class.new(@relation.sort_by(&block))
      end

      # @api public
      def rename(mapping, &block)
        self.class.new(@relation.rename(mapping, &block))
      end

      # @api public
      def join(other)
        self.class.new(@relation.join(other.relation))
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

      def aliases
        AliasSet.new(DataMapper::Inflector.singularize(relation.name), attributes)
      end

    end # class Relation
  end # class Mapper
end # module DataMapper
