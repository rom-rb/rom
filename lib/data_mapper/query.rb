module DataMapper

  # Represents a query for a restriction
  #
  class Query
    include Enumerable

    # Initializes a new query instance
    #
    # @param [Hash]
    #
    # @param [Mapper::AttributeSet]
    #
    # @return [undefined]
    #
    # @api private
    def initialize(options, attributes)
      @options    = options
      @attributes = attributes
    end

    # Iterate over attribute fields
    #
    # @return [self]
    #
    # @api private
    def each
      return to_enum unless block_given?

      @options.each do |name, value|
        yield(@attributes.field_name(name), value)
      end

      self
    end

  end # class Query

end # module DataMapper
