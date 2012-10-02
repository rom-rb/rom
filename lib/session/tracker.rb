module Session

  # Object state tracker that uses a simple hash
  class Tracker

    # Return state for object
    #
    # @param [Object] object
    #
    # @return [State]
    #   if object has tracked state
    #
    # @return [Object]
    #   otherwise value returned from block
    #
    # @api private
    #
    def get(object)
      @objects.fetch(object) { yield }
    end

    # Return state for identity
    #
    # @param [Object] identity
    #
    # @api private
    #
    # @return [State]
    #   if identity has tracked state
    #
    # @return [Object]
    #   otherwise value returned from block
    #
    def identity(identity)
      @identities.fetch(identity) { yield }
    end

    # Load state
    #
    # @param [State]
    #
    # @return [Object]
    #
    # @api private
    #
    def load(state)
      identity(state.identity) do
        store(state.loaded)
      end.object
    end

    # Persist state
    #
    # @param [State] state
    #
    # @return [self]
    #
    # @api private
    #
    def persist(state)
      delete(state)
      store(state.persist)

      self
    end

    # Test if object is tracked
    #
    # @return [true]
    #   if tracked
    #
    # @return [false}
    #   otherwise
    #
    # @api private
    #
    def include?(object)
      @objects.key?(object)
    end

    # Delete object state
    #
    # @param [State] state
    #
    # @return [self]
    #
    # @api private
    #
    def delete(state)
      @objects.delete(state.object)
      @identities.delete(state.identity)

      self
    end

  private

    # Initialize object
    #
    # @return [undefined]
    #
    # @api private
    #
    def initialize
      @objects, @identities = {}, {} 
    end

    # Store object state
    #
    # @param [State] state
    #
    # @return [State]
    #
    # @api private
    #
    def store(state)
      @objects[state.object]=state
      @identities[state.identity]=state

      state
    end
  end
end
