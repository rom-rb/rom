module DataMapper

  # Mapper
  #
  class Mapper
    include Enumerable
    extend DescendantsTracker, Options

    accept_options :model, :environment

    # The mapper's model
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

    # Return mapper's environment object
    #
    # @return [DataMapper::Environment]
    #
    # @api private
    attr_reader :environment

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
      klass = Builder.define_for(other.model, self, name)

      # FIXME: unify mapper building via environment
      klass.environment(other.environment)

      other.attributes.each do |attribute|
        klass.attributes << attribute
      end

      klass
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

    # Returns attribute set for this mapper class
    #
    # @return [AttributeSet]
    #
    # @api private
    def self.attributes
      @attributes ||= AttributeSet.new
    end

    # Finalizes attributes
    #
    # @return [self]
    #
    # @api private
    def self.finalize_attributes(registry)
      attributes.finalize(registry)
      self
    end

    # Initialize mapper instance using default settings from its class
    #
    # @return [undefined]
    #
    # @api private
    def initialize
      @model         = self.class.model
      @attributes    = self.class.attributes
      @environment   = self.class.environment
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
    # @return [Object]
    #   a domain model instance
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
    #   a domain model instance
    #
    # @return [Hash<Symbol, Object>]
    #
    # @api public
    def dump(object)
      @attributes.each_with_object({}) do |attribute, attributes|
        attributes[attribute.field] = object.send(attribute.name)
      end
    end

  end # class Mapper

end # module DataMapper
