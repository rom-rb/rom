module DataMapper
  class Session

    # Object state tracker that uses a simple hash
    class Tracker

      # Return state for object
      #
      # @param [Object] identity
      #
      # @return [State]
      #   if object has tracked state
      #
      # @return [Object]
      #   otherwise value returned from block
      #
      # @api private
      #
      def fetch(identity)
        @objects.fetch(identity) { yield }
      end

      # Test if tracker includes state for identity
      #
      # @param [Object] identity
      #
      # @return [true]
      #   if tracker has a state for identity
      #
      # @return [false]
      #   otherwise
      #
      # @api private
      #
      def include?(identity)
        @objects.key?(identity)
      end

      # Forget identity
      #
      # @param [Object] identity
      #
      # @return [self]
      #
      # @api private
      #
      def delete(identity)
        @objects.delete(identity)

        self
      end

      # Store object state
      #
      # @param [State] state
      #
      # @return [self]
      #
      # @api private
      #
      def store(state)
        @objects[state.identity]=state

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
        @objects = {}
      end
    end
  end
end
