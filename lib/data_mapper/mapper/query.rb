module DataMapper
  class Query
    include Enumerable

    def initialize(options, attributes)
      @options    = options
      @attributes = attributes
    end

    # @api public
    def each
      return to_enum unless block_given?
      @options.each do |name, value|
        yield(@attributes.field_name(name), value)
      end
      self
    end
  end
end # module DataMapper
