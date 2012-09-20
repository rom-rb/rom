require 'virtus/support/descendants_tracker'
require 'data_mapper/mapper/relationship_dsl'

module DataMapper

  # Abstract Mapper class
  #
  # @abstract
  class Mapper
    include Enumerable
    extend Virtus::DescendantsTracker
    extend RelationshipDsl

    def self.inherited(descendant)
      super

      descendant.model(model)
      descendant.repository(repository)
      attributes.each do |attribute|
        descendant.attributes << attribute
      end
      relationships.each do |relationship|
        descendant.relationships << relationship
      end
    end

    # @api public
    def self.[](model)
      mapper_registry[model]
    end

    # @api public
    def self.mapper_registry
      @mapper_registry ||= MapperRegistry.new
    end

    # @api public
    def self.relation_registry
      @relation_registry ||= RelationRegistry.new
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

    # Set or return the name of this mapper's default relation
    #
    # @api public
    def self.relation_name(name = Undefined)
      if name.equal?(Undefined)
        @relation_name
      else
        @relation_name = name
      end
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
    def self.map(name, *args)
      type    = Utils.extract_type(args)
      options = Utils.extract_options(args)
      options = options.merge(:type => type) if type

      attributes.add(name, options)
      self
    end

    # @api private
    def self.attributes
      @attributes ||= AttributeSet.new
    end

    # @api private
    def self.relationships
      @relationships ||= RelationshipSet.new
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
