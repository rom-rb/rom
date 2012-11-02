module DataMapper

  # Mapper
  #
  class Mapper
    include Enumerable
    extend DescendantsTracker

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
    attr_reader :model

    # This mapper's set of attributes to map
    #
    # @example
    #
    #   mapper = DataMapper[User]
    #   mapper.attributes
    #
    # @return [AttributeSet]
    #
    # @api public
    attr_reader :attributes

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

    # Returns a new mapper class derived from the given one
    #
    # @example
    #
    #   other = DataMapper[User].class
    #   DataMapper::Mapper.from(other, 'AdminMapper')
    #
    # @return [Mapper]
    #
    # @api public
    def self.from(other, name)
      klass = Builder::Class.define_for(other.model, self, name)

      other.attributes.each do |attribute|
        klass.attributes << attribute
      end

      other.relationships.each do |relationship|
        klass.relationships << relationship
      end

      klass
    end

    # Sets or returns the model for this mapper
    #
    # @example when setting the model
    #
    #   class UserMapper
    #     model User
    #   end
    #
    # @example when reading the model
    #
    #   mapper = DataMapper[User]
    #   mapper.class.model
    #
    # @param [Class] model to be set
    #
    # @return [Class, nil, self]
    #
    # @api public
    def self.model(model = Undefined)
      if model.equal?(Undefined)
        @model
      else
        @model = model
        self
      end
    end

    # Sets a mapping attribute
    #
    # @example
    #
    #   class UserMapper < DataMapper::Mapper
    #     map :id, Integer, :to => :user_id
    #   end
    #
    # @param [Symbol] name of the attribute
    # @param [*args]
    #
    # @return [self]
    #
    # @api public
    def self.map(name, *args)
      type    = Utils.extract_type(args)
      options = Utils.extract_options(args)
      options = options.merge(:type => type) if type

      if attributes[name]
        attributes << attributes[name].clone(options)
      else
        attributes.add(name, options)
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
    #     belongs_to :group
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

    # Returns a mapper instance for the given model
    #
    # @example
    #
    #   DataMapper[User] #=> user mapper instance
    #
    # @param [Class] model class
    #
    # @return [Mapper]
    #
    # @api public
    def self.[](model)
      mapper_registry[model]
    end

    # Returns attribute set for this mapper class
    #
    # @return [AttributeSet]
    #
    # @api private
    def self.attributes
      @attributes ||= AttributeSet.new
    end

    # Returns relationship set for this mapper class
    #
    # @return [RelationshipSet]
    #
    # @api private
    def self.relationships
      @relationships ||= RelationshipSet.new
    end

    # Returns mapper registry for this mapper class
    #
    # @return [MapperRegistry]
    #
    # @api private
    def self.mapper_registry
      @mapper_registry ||= MapperRegistry.new
    end

    # Finalizes this mapper class
    #
    # @example
    #   DataMapper::Mapper.finalize
    #
    # @abstract
    #
    # @return [self]
    #
    # @api public
    def self.finalize
      # noop
      self
    end

    # Finalizes attributes
    #
    # @return [self]
    #
    # @api private
    def self.finalize_attributes
      attributes.finalize
      self
    end

    # Shortcut for self.class.relations
    #
    # @see Engine#relations
    #
    # @example
    #   mapper = DataMapper[User]
    #   mapper.relations
    #
    # @return [RelationRegistry]
    #
    # @api public
    def relations
      self.class.relations
    end

    # @api private
    def initialize
      @model         = self.class.model
      @attributes    = self.class.attributes
      @relationships = self.class.relationships
    end

    # Loads a domain object
    #
    # @example
    #   mapper = DataMapper[User]
    #   tuple = { :id => 1, :name => 'John' }
    #   mapper.load(tuple)
    #
    # @param [(#each, #[])] tuple
    #
    # @return [Object] a domain model
    #
    # @api public
    def load(tuple)
      @model.new(@attributes.load(tuple))
    end

    # Dumps a domain object
    #
    # @example
    #   mapper = DataMapper[User]
    #   model  = SomeDomainModel.new
    #   mapper.dump(model)
    #
    # @param [Object] object
    #   a domain model
    #
    # @return [Hash]
    #
    # @api public
    def dump(object)
      @attributes.each_with_object({}) do |attribute, attributes|
        attributes[attribute.field] = object.send(attribute.name)
      end
    end

  end # class Mapper

end # module DataMapper
