module Session
  # An objects persistance state
  class ObjectState
    include Immutable

    # Return wrapped domain object
    #
    # @return [Object]
    #
    # @api private
    #
    attr_reader :object

    # Return dumped representation of object
    #
    # The dump is not cached.
    #
    # @return [Object]
    #   the dumped representation
    #
    # @api private
    #
    def dump
      @mapper.dump(@object)
    end

    # Return dumped key representation of object
    #
    # The key is not cached.
    #
    # @return [Object]
    #   the key
    #
    # @api private
    #
    def key
      @mapper.dump_key(@object)
    end

    # Update track
    #
    # Noop default implementation for all states.
    #
    # @param [Object] track
    #
    # @return [self]
    #
    # @api private
    #
    def update_track(track)
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
    def initialize(mapper, object)
      @mapper, @object = mapper,object
    end
  end
end
