module DataMapper
  # Represent a set of attribute aliases used in joined relations
  #
  class AliasSet
    include Enumerable

    # Prefix used for aliasing
    #
    # @return [Symbol]
    #
    # @api private
    attr_reader :prefix

    # AttributeSet instance from a mapper
    #
    # @return [AttributeSet]
    #
    # @api private
    attr_reader :attributes

    # An array of attributes that should be excluded from aliasing
    #
    # @return [Array<Symbol>]
    #
    # @api private
    attr_reader :excluded

    # Initialize an alias set instance
    #
    # @param [Symbol,#to_sym] prefix used for aliasing
    # @param [Mapper::AttributeSet] attributes
    # @param [Array] list of excluded attribute names
    #
    # @return [undefined]
    #
    # @api private
    def initialize(prefix, attributes = Mapper::AttributeSet.new, excluded = [])
      @prefix     = prefix.to_sym
      @attributes = attributes
      @excluded   = excluded
      @index      = attributes.alias_index(prefix, excluded)
    end

    # Iterate on alias index
    #
    # @return [self]
    #
    # @api private
    def each(&block)
      return to_enum unless block_given?
      @index.each(&block)
      self
    end

    # Returns a new alias set with excluded attribute names
    #
    # @return [AliasSet]
    #
    # @api private
    def exclude(*names)
      self.class.new(prefix, attributes, excluded.dup.concat(names))
    end

    # Returns a new alias set merged with the given one
    #
    # @return [AliasSet]
    #
    # @api private
    def merge(other)
      attributes = @attributes.merge(other.attributes)
      excluded   = @excluded.dup.concat(other.excluded)
      self.class.new(prefix, attributes, excluded)
    end

    # Returns hash representation of the alias set
    #
    # @return [Hash]
    #
    # @api private
    def to_hash
      @index
    end

  end # class AliasSet
end # module DataMapper
