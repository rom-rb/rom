module DataMapper

  # Abstract Mapper class
  #
  # @abstract
  class Mapper
    include Enumerable
    extend DescendantsTracker

    def self.from(other, name)
      mapper_name = name ? name : "#{other.model}Mapper"

      klass = Class.new(self)

      klass.class_eval <<-RUBY
        def self.name
          #{mapper_name.inspect}
        end
      RUBY

      klass.model(other.model)

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

    def self.has(cardinality, name, *args, &op)
      relationship = Relationship::Builder::Has.build(
        self, cardinality, name, *args, &op
      )

      relationships << relationship
    end

    def self.belongs_to(name, *args, &op)
      relationship = Relationship::Builder::BelongsTo.build(
        self, name, *args, &op
      )

      relationships << relationship
    end

    def self.n
      Infinity
    end

    # @api public
    def self.[](model)
      mapper_registry[model]
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
    def self.relation_registry
      @relation_registry ||= RelationRegistry.new
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

    # @api private
    def self.unique_alias(name, scope)
      "#{name}__#{scope}_alias#{[name, scope].join.hash}".to_sym
    end

    # @api private
    def unique_alias(name, scope)
      self.class.unique_alias(name, scope)
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
