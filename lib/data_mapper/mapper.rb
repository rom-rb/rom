module DataMapper

  # Abstract Mapper class
  #
  # @abstract
  class Mapper
    include Enumerable

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

    # Configure mapping of an attribute
    #
    # @example
    #
    #   class User::Mapper < DataMapper::Mapper
    #     map :name, :to => :username
    #   end
    #
    # @api public
    def self.map(*args)
      attributes.add(*args)
      self
    end

    # @api private
    def self.attributes
      @attributes ||= AttributeSet.new
    end

    # Load a domain object
    #
    # @api private
    def load(tuple)
      raise NotImplementedError, "#{self.class}#load is not implemented"
    end

  end # class Mapper
end # module DataMapper
