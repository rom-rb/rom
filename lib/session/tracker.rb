module Session

  # Object state tracker that uses a simple hash
  class Tracker

    # Return state for object
    #
    # @return [State]
    #   if object is found
    #
    # @return [Object]
    #   otherwise value returned from block
    #
    def get(object)
      @states.fetch(object) { yield }
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
      @states.key?(object)
    end

    # Store object state
    #
    # @param [Object] object
    # @param [State] state
    #
    # @return [self]
    #
    # @api private
    #
    def store(object, state)
      @states[object]=state
      self
    end

    # Delete object state
    #
    # @param [Object] object
    #
    # @return [self]
    #
    # @api private
    #
    def delete(object)
      @states.delete(object)
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
      @states = {}
    end
  end
end
