module Session
  # Abstract base class for object state
  class State
    include AbstractClass, Immutable

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
    # @return [Object]
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

    # Update track
    #
    # Noop default implementation for all states.
    #
    # @param [Tracker] tracker
    #
    # @return [self]
    #
    # @api private
    #
    def update_tracker(tracker)
      self
    end

    # Update identity map
    #
    # Noop default implementation for all states.
    #
    # @param [Object] identity_map
    #
    # @return [self]
    #
    # @api private
    #
    def update_identity(identity_map)
      self
    end

    # Empty identity map
    #
    # Noop default implementation for all states.
    #
    # @param [Object] identity_map
    #
    # @return [self]
    #
    # @api private
    #
    def delete_identity(identity_map)
      self
    end

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
    def delete
      raise StateError, "#{self.class.name} cannot be deleted"
    end

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
    def forget
      raise StateError, "#{self.class.name} cannot be forgotten"
    end

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
    def persist
      raise StateError, "#{self.class.name} cannot be persisted"
    end

  private

    # Initialize object state instance
    #
    # @param [Mapper] mapper the mapper for wrapped domain object
    # @param [Object] object the wrapped domain object
    #
    # @return [self]
    #
    # @api private
    #
    def initialize(mapping)
      @mapping = mapping
      @key  = mapping.key
      @dump = mapping.dump
    end
  end
end
