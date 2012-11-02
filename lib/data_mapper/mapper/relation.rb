module DataMapper
  class Mapper

    # Relation
    #
    # @api public
    class Relation < self
      alias_method :all, :to_a

      # The relation backing this mapper
      #
      # @example
      #
      #   mapper = DataMapper[Person]
      #   mapper.relation
      #
      # @return [RelationRegistry::RelationNode]
      #
      # @api public
      attr_reader :relation

      # Return a new mapper class derived from the given one
      #
      # @see Mapper.from
      #
      # @example
      #
      #   other = DataMapper[Person].class
      #   DataMapper::Mapper::Relation.from(other, 'AdminMapper')
      #
      # @return [Mapper::Relation]
      #
      # @api public
      def self.from(other, name = nil)
        klass = super
        klass.repository(other.repository)
        klass.relation_name(other.relation_name)
        klass
      end

      # Returns engine for this mapper
      #
      # @return [Engine]
      #
      # @api private
      def self.engine
        @engine ||= DataMapper.engines[repository]
      end

      # Returns relation registry for this mapper class
      #
      # @see Engine#relations
      #
      # @example
      #
      #   DataMapper::Mapper::Relation.relations
      #
      # @return [RelationRegistry]
      #
      # @api public
      def self.relations
        @relations ||= engine.relations
      end

      # Returns base relation for this mapper
      #
      # @example
      #
      #   DataMapper::Mapper::Relation.relation
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

      # Set or return the name of this mapper's repository
      #
      # @example when setting the repository name
      #
      #   class UserMapper
      #     repository :foo
      #   end
      #
      # @example when reading the repository name
      #
      #   mapper = DataMapper[User]
      #   mapper.class.repository
      #
      # @param [Symbol] name
      #   the repository name
      #
      # @return [Symbol, nil]
      #
      # @api public
      def self.repository(name = Undefined)
        if name.equal?(Undefined)
          @repository
        else
          @repository = name
        end
      end

      # Set or return the name of this mapper's relation
      #
      # @example when setting the relation name
      #
      #   class UserMapper
      #     relation_name :users
      #   end
      #
      # @example when reading the relation name
      #
      #   mapper = DataMapper[User]
      #   mapper.class.relation_name
      #
      # @param [Symbol] name
      #   the relation name
      #
      # @return [Symbol, nil]
      #
      # @api public
      def self.relation_name(name = Undefined)
        if name.equal?(Undefined)
          @relation_name
        else
          @relation_name = name
        end
      end

      # Mark the given attribute names as (part of) the key
      #
      # @example
      #
      #   class Person
      #     include DataMapper::Model
      #     attribute :id, Integer
      #   end
      #
      #   DataMapper.generate_mapper_for(Person, :postgres) do
      #     key :id
      #   end
      #
      # @param [(Symbol)] *names
      #   the attribute names that together consitute the key
      #
      # @return [self]
      #
      # @api public
      def self.key(*names)
        names.each do |name|
          attributes << attributes[name].clone(:key => true)
        end
      end

      # The aliases used for this mapper's instances
      #
      # @return [AliasSet]
      #
      # @api private
      def self.aliases
        @aliases ||= AliasSet.new(Inflector.singularize(relation_name), attributes)
      end

      # Perform finalization
      #
      # @api private
      def self.finalize
        Mapper.mapper_registry << new(relations.node_for(gateway_relation))
      end

      # Initialize a veritas mapper instance
      #
      # @example
      #
      #   class PersonMapper < DataMapper::Mapper::Relation
      #     relation_name :people
      #     model Person
      #     repository :postgres
      #   end
      #
      #   mapper = PersonMapper.new
      #
      # @param [Veritas::Relation] relation
      #   the relation to map from
      #
      # @param [AttributeSet] attributes
      #   the set of attributes to map
      #
      # @return [undefined]
      #
      # @api public
      def initialize(relation = self.class.relation, attributes = self.class.attributes)
        super()
        @relation   = relation
        @attributes = attributes
      end

      # Return a new instance with mapping that corresponds to aliases
      #
      # TODO find a better name
      #
      # @param [Hash] aliases
      #   the aliases to use in the returned instance
      #
      # @return [Mapper::Relation]
      #
      # @api private
      def remap(aliases)
        self.class.new(@relation, @attributes.remap(aliases))
      end

      # Iterate over the loaded domain objects
      #
      # @example
      #
      #   DataMapper[Person].each do |person|
      #     puts person.name
      #   end
      #
      # @yield [object] the loaded domain objects
      #
      # @yieldparam [Object] object
      #   the loaded domain object that is yielded
      #
      # @return [self]
      #
      # @api public
      def each
        return to_enum unless block_given?
        @relation.each { |tuple| yield load(tuple) }
        self
      end

      # The mapped relation's name
      #
      # @see Mapper::Relation.relation_name
      #
      # @example
      #
      #   mapper = DataMapper[Person]
      #   mapper.relation_name
      #
      # @return [Symbol]
      #
      # @api public
      def relation_name
        self.class.relation_name
      end

      # The mapper's model
      #
      # @see Mapper::Relation.model
      #
      # @example
      #
      #   mapper = DataMapper[Person]
      #   mapper.model
      #
      # @return [::Class]
      #   a domain model class
      #
      # @api public
      def model
        self.class.model
      end

      # The mapper's human readable representation
      #
      # @example
      #
      #   mapper = DataMapper[Person]
      #   puts mapper.inspect
      #
      # @return [String]
      #
      # @api public
      def inspect
        "<##{self.class.name}:#{object_id} @model=#{@model} @repository=#{self.class.repository} @relation=#{@relation}>"
      end

      # Return a mapper for iterating over the relation restricted with options
      #
      # @see Veritas::Relation#restrict
      #
      # @example
      #
      #   mapper = DataMapper[Person]
      #   mapper.find(:name => 'John').to_a
      #
      # @param [Hash] options
      #   the options to restrict the relation
      #
      # @return [Mapper::Relation]
      #
      # @api public
      def find(options)
        restriction = @relation.restrict(Query.new(options, @attributes))
        self.class.new(restriction)
      end

      # Return a mapper for iterating over the relation ordered by *order
      #
      # @see Veritas::Relation#sort_by
      #
      # @example
      #
      #   mapper = DataMapper[Person]
      #   mapper.order(:name).to_a
      #
      # @param [(Symbol)] *order
      #   the attribute names to order by
      #
      # @return [Mapper::Relation]
      #
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

      # Return a mapper for iterating over the relation ordered by *order
      #
      # @example
      #
      #   mapper = DataMapper[Person]
      #   mapper.one(:name => 'John')
      #
      # @param [Hash] options
      #   the options to restrict the relation
      #
      # @raise RuntimeError
      #   if more than one domain object was found
      #
      # @return [Object]
      #   a domain object
      #
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

      # Return a mapper for iterating over domain objects with loaded relationships
      #
      # @example
      #
      #   DataMapper[Person].include(:tasks).each do |person|
      #     person.tasks.each do |task|
      #       puts task.name
      #     end
      #   end
      #
      # @param [Symbol] name
      #   the name of the relationship to include
      #
      # @return [Mapper::Relation]
      #
      # @api public
      def include(name)
        Mapper.mapper_registry[self.class.model, relationships[name]]
      end

      # Return a mapper for iterating over a restricted set of domain objects
      #
      # @example
      #
      #   DataMapper[Person].restrict { |r| r.name.eq('John') }.each do |person|
      #     puts person.name
      #   end
      #
      # @param [Proc] &block
      #   the block to restrict the relation with
      #
      # @return [Mapper::Relation]
      #
      # @api public
      def restrict(&block)
        self.class.new(@relation.restrict(&block))
      end

      # Return a mapper for iterating over a sorted set of domain objects
      #
      # @see Veritas::Relation#sort_by
      #
      # @example with directions
      #
      #   DataMapper[Person].sort_by(:name).each do |person|
      #     puts person.name
      #   end
      #
      # @example with a block
      #
      #   DataMapper[Person].sort_by { |r| [ r.name.desc ] }.each do |person|
      #     puts person.name
      #   end
      #
      # @param [(Symbol)] *args
      #   the sort directions
      #
      # @param [Proc] &block
      #   the block to evaluate for the sort directions
      #
      # @return [Mapper::Relation]
      #
      # @api public
      def sort_by(*args, &block)
        self.class.new(@relation.sort_by(*args, &block))
      end

      # Return a mapper for iterating over domain objects with renamed attributes
      #
      # @example
      #
      #   DataMapper[Person].rename(:name => :nickname).each do |person|
      #     puts person.nickname
      #   end
      #
      # @param [Hash] aliases
      #   the old and new attribute names as alias pairs
      #
      # @return [Mapper::Relation]
      #
      # @api public
      def rename(aliases)
        self.class.new(@relation.rename(aliases))
      end

      # Return a mapper for iterating over the result of joining other with self
      #
      # TODO investigate if the following example works
      #
      # @example
      #
      #   DataMapper[Person].join(DataMapper[Task]).each do |person|
      #     puts person.tasks.size
      #   end
      #
      # @param [Mapper::Relation] other
      #   the other mapper to join with self
      #
      # @return [Mapper::Relation]
      #
      # @api public
      def join(other)
        self.class.new(@relation.join(other.relation))
      end

    end # class Relation
  end # class Mapper
end # module DataMapper
