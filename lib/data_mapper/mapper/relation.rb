module DataMapper
  class Mapper

    # Relation
    #
    # @api public
    class Relation < self
      alias_method :all, :to_a

      attr_reader :relation

      # @see [DataMapper::Mapper.from]
      def self.from(other, name = nil)
        klass = super
        klass.repository(other.repository)
        klass.relation_name(other.relation_name)
        klass
      end

      # Returns engine for this mapper
      #
      # @return [DataMapper::Engine]
      #
      # @api private
      def self.engine
        @engine ||= DataMapper.engines[repository]
      end

      # Returns relation registry for this mapper class
      #
      # @return [DataMapper::RelationRegistry]
      #
      # @api public
      def self.relations
        @relations ||= engine.relations
      end

      # Returns base relation for this mapper
      #
      # @return [Object]
      #
      # @api public
      def self.relation
        @relation ||= engine.base_relation(relation_name, attributes.header)
      end

      # Returns gateway relation for this mapper class
      #
      # @return [Object]
      #
      # @api private
      def self.gateway_relation
        @gateway_relation ||= engine.gateway_relation(relation)
      end

      # Sets or returns the name of this mapper's repository
      #
      # @api public
      def self.repository(name = Undefined)
        if name.equal?(Undefined)
          @repository
        else
          @repository = name
        end
      end

      # Sets or returns the name of this mapper's relation
      #
      # @api public
      def self.relation_name(name = Undefined)
        if name.equal?(Undefined)
          @relation_name
        else
          @relation_name = name
        end
      end

      # @api public
      def self.key(*names)
        names.each do |name|
          attributes << attributes[name].clone(:key => true)
        end
      end

      # @api private
      def self.aliases
        @aliases ||= AliasSet.new(Inflector.singularize(relation_name), attributes)
      end

      # @api private
      def self.finalize
        Mapper.mapper_registry << new(relations.node_for(gateway_relation))
      end

      # Initialize a veritas mapper instance
      #
      # @param [Veritas::Relation]
      #
      # @return [undefined]
      #
      # @api public
      def initialize(relation = self.class.relation, attributes = self.class.attributes)
        super()
        @relation   = relation
        @attributes = attributes
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
      def relation_name
        self.class.relation_name
      end

      # @api public
      def model
        self.class.model
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
        Mapper.mapper_registry[self.class.model, relationships[name]]
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

    end # class Relation
  end # class Mapper
end # module DataMapper
