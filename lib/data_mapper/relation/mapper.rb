module DataMapper
  module Relation

    # Relation
    #
    # @api public
    class Mapper < DataMapper::Mapper
      alias_method :all, :to_a

      accept_options :relation_name, :repository

      # The relation backing this mapper
      #
      # @example
      #
      #   mapper = DataMapper[Person]
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
      #   mapper = DataMapper[User]
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
      #   other = DataMapper[Person].class
      #   DataMapper::Relation::Mapper.from(other, 'AdminMapper')
      #
      # @return [Mapper]
      #
      # @api public
      def self.from(other, name = nil)
        klass = super
        klass.repository(other.repository)
        klass.relation_name(other.relation_name)
        other.relationships.each do |relationship|
          klass.relationships << relationship
        end
        klass
      end

      # Returns engine for this mapper
      #
      # @return [Engine]
      #
      # @api private
      def self.engine(engine = nil)
        @engine ||= engine
      end

      # Returns relation registry for this mapper class
      #
      # @see Engine#relations
      #
      # @example
      #
      #   DataMapper::Relation::Mapper.relations
      #
      # @return [Graph]
      #
      # @api public
      def self.relations
        @relations ||= engine.relations
      end

      # Returns base relation for this mapper
      #
      # @example
      #
      #   DataMapper::Relation::Mapper.relation
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
        self
      end

      # Establishes a relationship with the given cardinality and name
      #
      # @example
      #
      #   class UserMapper < DataMapper::Mapper
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
      #   class UserMapper < DataMapper::Mapper
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
      #   class UserMapper
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

      # Initialize a relation mapper instance
      #
      # @example
      #
      #   class PersonMapper < DataMapper::Relation::Mapper
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
      # @param [DataMapper::Mapper::AttributeSet] attributes
      #   the set of attributes to map
      #
      # @return [undefined]
      #
      # @api public
      def initialize(relation = self.class.relation, attributes = self.class.attributes)
        super()
        @relation      = relation
        @attributes    = attributes
        @relationships = self.class.relationships
      end

      # Shortcut for self.class.relations
      #
      # @see Engine#relations
      #
      # @example
      #   mapper = DataMapper[User]
      #   mapper.relations
      #
      # @return [Graph]
      #
      # @api public
      def relations
        self.class.relations
      end

      # The mapped relation's name
      #
      # @see Relation::Mapper.relation_name
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
        relation.each { |tuple| yield load(tuple) }
        self
      end

      # Return a mapper for iterating over the relation restricted with options
      #
      # @see Veritas::Relation#restrict
      #
      # @example
      #
      #   mapper = mappers[Person]
      #   mapper.find(:name => 'John').all
      #
      # @param [Hash] conditions
      #   the options to restrict the relation
      #
      # @return [Relation::Mapper]
      #
      # @api public
      def find(conditions = {})
        new(relation.restrict(Query.new(conditions, attributes)))
      end

      # Return a mapper for iterating over the relation ordered by *order
      #
      # @example
      #
      #   mapper = DataMapper[Person]
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
      def one(conditions = {})
        results = find(conditions).to_a
        assert_exactly_one_tuple(results.size)
        results.first
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
      #   mapper = DataMapper[Person]
      #   mapper.order(:name).to_a
      #
      # @param [(Symbol)] *order
      #   the attribute names to order by
      #
      # @return [Relation::Mapper]
      #
      # @api public
      def order(*names)
        order_attributes = names.map { |attribute| attributes.field_name(attribute) }
        order_attributes.concat(attributes.fields).uniq!
        new(relation.order(*order_attributes))
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

      # Set limit for the relation
      #
      # @example
      #
      #   env[Person].limit(3).all
      #
      # @param [Integer]
      #
      # @return [Relation::Mapper]
      #
      # @api public
      def limit(count)
        new(relation.take(count))
      end

      # Set offset for the relation
      #
      # @example
      #
      #   env[Person].limit(20).offset(2).all
      #
      # @param [Integer]
      #
      # @return [Relation::Mapper]
      #
      # @api public
      def offset(num)
        new(relation.skip(num))
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
      #   DataMapper[Person].join(DataMapper[Task]).each do |person|
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
      #   DataMapper[Person].include(:tasks).each do |person|
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

      # FIXME: add support for composite keys
      #
      # @api public
      def insert(object)
        key_name  = attributes.key[0].name
        tuple     = dump(object)
        tuple.delete(key_name)
        key_value = relation.insert(tuple)

        object.public_send("#{key_name}=", key_value)

        object
      end

      # FIXME: add support for composite keys
      #
      # Persist changes made to a given domain object
      #
      # @example
      #
      #   mapper = mappers[User]
      #
      #   user = mapper.find(:id => 1)
      #   user.age = 21
      #
      #   mapper.update(user, :age)
      #
      # @param [Object] domain object to be updated
      # @param [Array<Symbol>] names of attributes for the update
      #
      # @return [Integer] number of affected "rows"
      #
      # @api public
      def update(object, *names)
        key_name  = attributes.key[0].name
        key_value = object.public_send(key_name)
        tuple     = dump(object)
        fields    = names.map { |name| attributes[name].field }
        relation.update({ key_name => key_value }, tuple.reject { |k, _| !fields.include?(k) })
      end

      # FIXME: add support for composite keys
      #
      # @api public
      def delete(object)
        key_name  = attributes.key[0].name
        key_value = object.public_send(key_name)
        relation.delete(key_name => key_value)
        object
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
        "#<#{self.class.name} @model=#{model.name} @relation_name=#{relation_name} @repository=#{self.class.repository}>"
      end

      private

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
        self.class.new(relation, attributes)
      end

    end # class Mapper

  end # module Relation
end # module DataMapper
