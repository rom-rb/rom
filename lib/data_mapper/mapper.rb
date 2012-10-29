module DataMapper

  # Abstract Mapper class
  #
  # @abstract
  class Mapper
    include Enumerable
    extend DescendantsTracker

    # TODO: refactor, add specs
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

    # Set or return the model for this mapper
    #
    # @api public
    def self.model(model = Undefined)
      if model.equal?(Undefined)
        @model
      else
        @model = model
      end
    end

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

    # TODO: add specs
    def self.has(cardinality, name, *args, &op)
      relationship = Relationship::Builder::Has.build(
        self, cardinality, name, *args, &op
      )

      relationships << relationship
    end

    # TODO: add specs
    def self.belongs_to(name, *args, &op)
      relationship = Relationship::Builder::BelongsTo.build(
        self, name, *args, &op
      )

      relationships << relationship
    end

    # TODO: add specs
    def self.n
      Infinity
    end

    # @api public
    def self.[](model)
      mapper_registry[model]
    end

    # TODO: add specs
    def self.relation
      raise NotImplementedError, "#{self.class}.relation must be implemented"
    end

    # @api private
    def self.attributes
      @attributes ||= AttributeSet.new
    end

    # @api private
    def self.relationships
      @relationships ||= RelationshipSet.new
    end

    # @api public
    def self.mapper_registry
      @mapper_registry ||= MapperRegistry.new
    end

    # @api public
    def self.relations
      @relations ||= engine.relations
    end

    # TODO: add specs
    def self.gateway_relation
      @gateway_relation ||= engine.gateway_relation(relation)
    end

    # @api public
    def self.finalize
      # noop
      self
    end

    # @api private
    def self.finalize_attributes
      attributes.finalize
    end

    # @api private
    def self.finalize_relationships
      relationships.finalize
    end

    # @api public
    # TODO: add specs
    def relations
      self.class.relations
    end

    # Load a domain object
    #
    # @api private
    def load(tuple)
      raise NotImplementedError, "#{self.class} must implement #load"
    end

    # Dump a domain object
    #
    # @api private
    def dump(object)
      raise NotImplementedError, "#{self.class} must implement #dump"
    end

  end # class Mapper
end # module DataMapper
