module ROM

  # Represents a query for a restriction
  #
  class Query
    include Enumerable

    attr_reader :options

    attr_reader :attributes

    # @api private
    attr_reader :index
    alias_method :to_h, :index

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
      @options, @attributes = options, attributes
      initialize_index
    end

    # Iterate over attribute fields
    #
    # @return [self]
    #
    # @api private
    def each(&block)
      return to_enum unless block_given?
      index.each(&block)
      self
    end

    private

    # @api private
    def initialize_index
      @index = options.each_with_object({}) do |(name, value), index|
        index[attributes.field_name(name)] = value
      end
    end

  end # class Query

end # module ROM
