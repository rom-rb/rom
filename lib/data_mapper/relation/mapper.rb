module DataMapper
  module Relation

    # Relation
    #
    # @api public
    class Mapper < DataMapper::Mapper

      include Equalizer.new(:environment, :model, :attributes, :relationships, :relation)

      DEFAULT_LIMIT_FOR_ONE = 2

      alias_method :all, :to_a

      accept_options :relation_name, :repository

      # Return the mapper's environment object
      #
      # @return [Environment]
      #
      # @api private
      attr_reader :environment

      # The relation backing this mapper
      #
      # @example
      #
      #   mapper = env[Person]
      #   mapper.relation
      #
      # @return [Graph::Node]
      #
      # @api public
      attr_reader :relation

      # This mapper's set of relationships to map
      #
      # @example
      #
      #   mapper = env[User]
      #   mapper.relationships
      #
      # @return [RelationshipSet]
      #
      # @api public
      attr_reader :relationships

      # Return a new mapper class derived from the given one
      #
      # @see Mapper.from
      #
      # @example
      #
      #   other = env[Person].class
      #   DataMapper::Relation::Mapper.from(other, 'AdminMapper')
      #
      # @return [Mapper]
      #
      # @api public
      def self.from(other, _name = nil)
        klass = super
        klass.repository(other.repository)
        klass.relation_name(other.relation_name)
        other.relationships.each do |relationship|
          klass.relationships << relationship
        end
        klass
      end

      # Returns relation for this mapper class
      #
      # @example
      #
      #   DataMapper::Relation::Mapper.relation
      #
      # @return [Object]
      #
      # @api public
      def self.relation
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
      #   env.build(Person, :postgres) do
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
        attribute_set = attributes
        names.each do |name|
          attribute_set << attribute_set[name].clone(:key => true)
        end
        self
      end

      # Establishes a relationship with the given cardinality and name
      #
      # @example
      #
      #   class UserMapper < DataMapper::Relation::Mapper
      #     has 1,    :address, Address
      #     has 0..n, :orders,  Order
      #   end
      #
      # @param [Fixnum,Range]
      # @param [Symbol] name for the relationship
      # @param [*args]
      # @param [Proc] optional operation that should be evaluated on the relation
      #
      # @return [self]
      #
      # @api public
      def self.has(cardinality, name, *args, &op)
        relationship = Relationship::Builder::Has.build(
          self, cardinality, name, *args, &op
        )

        relationships << relationship

        self
      end

      # Establishes a one-to-many relationship
      #
      # @example
      #
      #   class UserMapper < DataMapper::Relation::Mapper
      #     belongs_to :group, Group
      #   end
      #
      # @param [Symbol]
      # @param [*args]
      # @param [Proc] optional operation that should be evaluated on the relation
      #
      # @return [self]
      #
      # @api public
      def self.belongs_to(name, *args, &op)
        relationship = Relationship::Builder::BelongsTo.build(
          self, name, *args, &op
        )

        relationships << relationship

        self
      end

      # Returns infinity constant
      #
      # @example
      #
      #   class UserMapper < DataMapper::Relation::Mapper
      #     has n, :orders, Order
      #   end
      #
      # @return [Float]
      #
      # @api public
      def self.n
        Infinity
      end

      # Returns relationship set for this mapper class
      #
      # @return [RelationshipSet]
      #
      # @api private
      def self.relationships
        @relationships ||= RelationshipSet.new
      end

      def self.default_relation(environment)
        relation || environment.repository(repository).get(relation_name)
      end

      # Initialize a relation mapper instance
      #
      # @param [Environment] environment
      #   the new mapper's environment
      #
      # @param [Veritas::Relation] relation
      #   the relation to map from
      #
      # @param [DataMapper::Mapper::AttributeSet] attributes
      #   the set of attributes to map
      #
      # @return [undefined]
      #
      # @api private
      def initialize(environment, relation = default_relation(environment), attributes = self.class.attributes)
        super(relation)
        @environment   = environment
        @relation      = relation
        @attributes    = attributes
        @relationships = self.class.relationships
      end

      # Shortcut for self.class.relations
      #
      # @see Engine#relations
      #
      # @example
      #   mapper = env[User]
      #   mapper.relations
      #
      # @return [Graph]
      #
      # @api public
      def relations
        environment.relations
      end

      # The mapped relation's name
      #
      # @see Relation::Mapper.relation_name
      #
      # @example
      #
      #   mapper = env[Person]
      #   mapper.relation_name
      #
      # @return [Symbol]
      #
      # @api public
      def relation_name
        self.class.relation_name
      end

      # Return a mapper for iterating over the relation restricted with options
      #
      # @see Veritas::Relation#restrict
      #
      # @example
      #
      #   mapper = env[Person]
      #   mapper.find(:name => 'John').all
      #
      # @param [Hash] conditions
      #   the options to restrict the relation
      #
      # @return [Relation::Mapper]
      #
      # @api public
      def find(conditions = EMPTY_HASH)
        new(restricted_relation(conditions))
      end

      # Return a mapper for iterating over the relation ordered by *order
      #
      # @example
      #
      #   mapper = env[Person]
      #   mapper.one(:name => 'John')
      #
      # @param [Hash] conditions
      #   the options to restrict the relation
      #
      # @raise [NoTuplesError]
      #   raised if no tuples are returned
      # @raise [ManyTuplesError]
      #   raised if more than one tuple is returned
      #
      # @return [Object]
      #   a domain object
      #
      # @api public
      def one(conditions = EMPTY_HASH)
        results = new(limited_relation(conditions, DEFAULT_LIMIT_FOR_ONE)).to_a
        assert_exactly_one_tuple(results.size)
        results.first
      end

      # Return a mapper for iterating over a restricted set of domain objects
      #
      # @example
      #
      #   env[Person].restrict { |r| r.name.eq('John') }.each do |person|
      #     puts person.name
      #   end
      #
      # @param [Proc] &block
      #   the block to restrict the relation with
      #
      # @return [Relation::Mapper]
      #
      # @api public
      def restrict(&block)
        new(relation.restrict(&block))
      end

      # Return a mapper for iterating over the relation ordered by *order
      #
      # @see Veritas::Relation#sort_by
      #
      # @example
      #
      #   mapper = env[Person]
      #   mapper.order(:name).to_a
      #
      # @param [(Symbol)] *order
      #   the attribute names to order by
      #
      # @return [Relation::Mapper]
      #
      # @api public
      def order(*names)
        attribute_set = attributes
        order_attributes = names.map { |attribute|
          attribute_set.field_name(attribute)
        }
        order_attributes.concat(attribute_set.fields).uniq!
        new(relation.order(*order_attributes))
      end

      # Return a mapper for iterating over a sorted set of domain objects
      #
      # @see Veritas::Relation#sort_by
      #
      # @example with directions
      #
      #   env[Person].sort_by(:name).each do |person|
      #     puts person.name
      #   end
      #
      # @example with a block
      #
      #   mappers[Person].sort_by { |r| [ r.name.desc ] }.each do |person|
      #     puts person.name
      #   end
      #
      # @param [(Symbol)] *args
      #   the sort directions
      #
      # @param [Proc] &block
      #   the block to evaluate for the sort directions
      #
      # @return [Relation::Mapper]
      #
      # @api public
      def sort_by(*args, &block)
        new(relation.sort_by(*args, &block))
      end

      # Limit the underlying ordered relation to the first +limit+ tuples
      #
      # @example
      #
      #   people = env[Person].sort_by { |r| [ r.id.asc ] }
      #   people.take(7)
      #
      # @param [Integer] limit
      #   the maximum number of tuples in the limited relation
      #
      # @return [Mapper]
      #   a new mapper backed by a relation with the first +limit+ tuples
      #
      # @raise [Veritas::OrderedRelationRequiredError]
      #   raised if the operand is unordered
      #
      # @api public
      def take(limit)
        new(relation.take(limit))
      end

      # Limit the underlying ordered relation to the first +limit+ tuples
      #
      # @example with no limit
      #
      #   people = env[Person].sort_by { |r| [ r.id.asc ] }
      #   people.first
      #
      # @example with a limit
      #
      #   people = env[Person].sort_by { |r| [ r.id.asc ] }
      #   people.first(7)
      #
      # @param [Integer] limit
      #   optional number of tuples from the beginning of the relation
      #
      # @return [Mapper]
      #   a new mapper backed by a relation with the first +limit+ tuples
      #
      # @api public
      def first(limit = 1)
        new(relation.first(limit))
      end

      # Limit the underlying ordered relation to the last +limit+ tuples
      #
      # @example with no limit
      #   limited_relation = relation.last
      #
      # @example with a limit
      #   limited_relation = relation.last(7)
      #
      # @param [Integer] limit
      #   optional number of tuples from the end of the relation
      #
      # @return [Mapper]
      #   a new mapper backed by a relation with the last +limit+ tuples
      #
      # @api public
      def last(limit = 1)
        new(relation.last(limit))
      end

      # Drop tuples before +offset+ in an ordered relation
      #
      # @example
      #
      #   people = env[Person].sort_by { |r| [ r.id.asc ] }
      #   people.drop(7)
      #
      # @param [Integer] offset
      #   the offset of the relation to drop
      #
      # @return [Relation::Mapper]
      #   a new mapper backed by the offset relation
      #
      # @raise [Veritas::OrderedRelationRequiredError]
      #   raised if the operand is unordered
      #
      # @api public
      def drop(offset)
        new(relation.drop(offset))
      end

      # Return a mapper for iterating over domain objects with renamed attributes
      #
      # @example
      #
      #   env[Person].rename(:name => :nickname).each do |person|
      #     puts person.nickname
      #   end
      #
      # @param [Hash] aliases
      #   the old and new attribute names as alias pairs
      #
      # @return [Relation::Mapper]
      #
      # @api public
      def rename(aliases)
        new(relation.rename(aliases))
      end

      # Return a mapper for iterating over the result of joining other with self
      #
      # TODO investigate if the following example works
      #
      # @example
      #
      #   env[Person].join(env[Task]).each do |person|
      #     puts person.tasks.size
      #   end
      #
      # @param [Relation::Mapper] other
      #   the other mapper to join with self
      #
      # @return [Relation::Mapper]
      #
      # @api public
      def join(other)
        new(relation.join(other.relation))
      end

      # Return a new instance with mapping that corresponds to aliases
      #
      # TODO find a better name
      #
      # @param [Graph::Node::Aliases, Hash] aliases
      #   the aliases to use in the returned instance
      #
      # @return [Relation::Mapper]
      #
      # @api private
      def remap(aliases)
        new(relation, attributes.remap(aliases))
      end

      # Return a mapper for iterating over domain objects with loaded relationships
      #
      # @example
      #
      #   env[Person].include(:tasks).each do |person|
      #     person.tasks.each do |task|
      #       puts task.name
      #     end
      #   end
      #
      # @param [Symbol] name
      #   the name of the relationship to include
      #
      # @return [Relation::Mapper]
      #
      # @api public
      def include(name)
        environment.registry[model, relationships[name]]
      end

      # Insert +tuples+ into the underlying relation
      #
      # @example
      #
      #   person = Person.new(:id => 1, :name => 'John')
      #   env[Person].insert([ person ])
      #
      # @param [Enumerable] object
      #   an enumerable coercible by {Veritas::Relation.coerce}
      #
      # @return [Mapper]
      #   a new mapper backed by a relation containing +object+
      #
      # @api public
      def insert(object)
        new(relation.insert(dump(object)))
      end

      # Update +tuples+ in the underlying relation
      #
      # @example
      #
      #   person = Person.new(:id => 1, :name => 'John')
      #   env[Person].update([ person ])
      #
      # @param [Enumerable] tuples
      #   an enumerable coercible by {Veritas::Relation.coerce}
      #
      # @return [Node]
      #   a new node backed by a relation including +tuples+
      #
      # @raise [NotImplementedError]
      #   this method is not yet implemented
      #
      # @api public
      def update(object)
        new(relation.update(dump(object)))
      end

      # Delete +object+ from the underlying relation
      #
      # @example
      #
      #   person = Person.new(:id => 1, :name => 'John')
      #   mapper = env[Person]
      #   mapper.insert([ person ])
      #   mapper.delete([ person ])
      #
      # @param [Enumerable] object
      #   an enumerable coercible by {Veritas::Relation.coerce}
      #
      # @return [Mapper]
      #   a new mapper backed by a relation excluding +object+
      #
      # @api public
      def delete(object)
        new(relation.delete(dump(object)))
      end

      # Replace the underlying relation with +object+
      #
      # @example
      #
      #   john  = Person.new(:id => 1, :name => 'John')
      #   jane  = Person.new(:id => 2, :name => 'Jane')
      #   alice = Person.new(:id => 1, :name => 'Jane')
      #
      #   mapper = env[Person]
      #   mapper.insert([ john, jane ])
      #   mapper.replace([ alice ])
      #
      # @param [Enumerable] object
      #   an enumerable coercible by {Veritas::Relation.coerce}
      #
      # @return [Mapper]
      #   a new mapper backed by a relation only including +object+
      #
      # @api public
      def replace(object)
        new(relation.replace(dump(object)))
      end

      # The mapper's human readable representation
      #
      # @example
      #
      #   mapper = env[Person]
      #   puts mapper.inspect
      #
      # @return [String]
      #
      # @api public
      def inspect
        klass = self.class
        "#<#{klass.name} @model=#{model.name} @relation_name=#{relation_name} @repository=#{klass.repository}>"
      end

      private

      def default_relation(environment)
        self.class.default_relation(environment)
      end

      def restricted_relation(conditions)
        relation.restrict(Query.new(conditions, attributes))
      end

      def limited_relation(conditions, limit)
        restricted_relation(conditions).ordered.take(limit)
      end

      # Assert exactly one tuple is returned
      #
      # @return [undefined]
      #
      # @raise [NoTuplesError]
      #   raised if no tuples are returned
      # @raise [ManyTuplesError]
      #   raised if more than one tuple is returned
      #
      # @api private
      def assert_exactly_one_tuple(size)
        if size.zero?
          raise NoTuplesError, 'one tuple expected, but none was returned'
        elsif size > 1
          raise ManyTuplesError, "one tuple expected, but #{size} were returned"
        end
      end

      # Return a new mapper instance
      #
      # @param [Graph::Node]
      #
      # @api private
      def new(relation, attributes = self.attributes)
        self.class.new(environment, relation, attributes)
      end

    end # class Mapper

  end # module Relation
end # module DataMapper
