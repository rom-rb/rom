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
    def self.model(model=nil)
      @model ||= model
    end

    # Set or return the name of this mapper's default relation
    #
    # @api public
    def self.relation_name(name=nil)
      @relation_name ||= name
    end

    # Set or return the name of this mapper's default repository
    #
    # @api public
    def self.repository(name=nil)
      @repository ||= name
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
    def self.map(name, options = {})
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
