module DataMapper
  # Abstract base class for object state
  class State
    include AbstractClass, Immutable, Equalizer.new(:mapping, :dump, :key)

    # Return domain object
    #
    # @return [Object]
    #
    # @api private
    #
    def object
      mapping.object
    end

    # Return mapper
    #
    # @return [Mapper]
    #
    # @api private
    #
    def mapper
      mapping.mapper
    end

    # Return mapping
    #
    # @return [Mapping]
    #
    # @api private
    #
    attr_reader :mapping

    # Return dumped representation of object
    #
    # @return [Object]
    #   the dumped representation
    #
    # @api private
    #
    attr_reader :dump

    # Return dumped key representation of object
    #
    # @return [Object]
    #   the key
    #
    # @api private
    #
    attr_reader :key

    # Delete domain object
    #
    # Default implementation for all subclasses.
    #
    # @raise [StateError]
    #
    # @return [undefined]
    #
    # @api private
    #
    abstract_method :delete

    # Forget domain object
    #
    # Default implementation for all subclasses.
    #
    # @raise [StateError]
    #
    # @return [undefined]
    #
    # @api private
    #
    abstract_method :forget

    # Persist domain object
    #
    # Default implementation for all subclasses.
    #
    # @raise [StateError]
    #
    # @return [undefined]
    #
    # @api private
    #
    abstract_method :persist

    # Return identity of object
    #
    # @return [Object]
    # 
    # @api private
    #
    def identity
      Identity.new(object.class, key)
    end
    memoize :identity

  private

    # Initialize object 
    #
    # @param [State|Mapping] context
    #
    # @return [self]
    #
    # @api private
    #
    def initialize(context)
      @key     = context.key
      @dump    = context.dump
      @mapping = context.mapping
    end
  end
end
