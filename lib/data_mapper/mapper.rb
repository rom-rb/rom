require 'virtus/support/descendants_tracker'

module DataMapper

  # Abstract Mapper class
  #
  # @abstract
  class Mapper
    include Enumerable
    extend Virtus::DescendantsTracker

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
      DataMapper.relation_registry << base_relation
      self
    end

    # @api private
    def self.finalize_attributes
      attributes.each { |attribute| attribute.finalize }
    end

    # @api private
    def self.finalize_relationships
      relationships.each { |relationship| relationship.finalize }
    end

    # @api public
    def self.map(name, options = {})
      attributes.add(name, options)
      self
    end

    # @api public
    def self.has(cardinality, name, options = {}, &operation)
      if cardinality == 1
        source = options[:through]

        if source
          relationships.add_through(source, name, &operation)
        else
          relationships.add(name, options.merge(
            :type => Relationship::OneToOne, :operation => operation))
        end
      else
        raise "Relationship not supported"
      end
    end

    # @api public
    def self.belongs_to(model_name, options = {}, &operation)
      relationships.add(model_name, options.merge(
        :type => Relationship::ManyToOne, :operation => operation))
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
      raise NotImplementedError, "#{self.class}#load is not implemented"
    end

    # Dump a domain object
    #
    # @api private
    def dump(object)
      raise NotImplementedError, "#{self.class}#dump is not implemented"
    end

  end # class Mapper
end # module DataMapper
