module DataMapper
  class AliasSet
    include Enumerable

    attr_reader :prefix
    attr_reader :attributes
    attr_reader :excluded

    # @api private
    def initialize(prefix, attributes = Mapper::AttributeSet.new, excluded = [])
      @prefix     = prefix
      @attributes = attributes
      @excluded   = excluded
      @index      = attributes.alias_index(prefix, excluded)
    end

    # @api private
    def each(&block)
      return to_enum unless block_given?
      @index.each(&block)
      self
    end

    # @api private
    def exclude(*names)
      self.class.new(prefix, attributes, excluded.dup.concat(names))
    end

    # @api private
    def merge(other)
      attributes = @attributes.merge(other.attributes)
      excluded   = @excluded.dup.concat(other.excluded)
      self.class.new(prefix, attributes, excluded)
    end

    # @api private
    def to_hash
      @index
    end

  end # class AliasSet
end # module DataMapper
