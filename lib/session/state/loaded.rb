module Session
  class State
    # An State that represents a loaded domain object.
    class Loaded < self

      # Test if object is dirty
      #
      # @return [true]
      #   if object is dirty
      #
      # @return [false]
      #   otherwise
      #
      # @api privateo
      #
      def dirty?
        !dirty.clean?
      end

      # Invoke transition to forgotten object state after deleting via mapper
      #
      # @return [undefined]
      #
      # @api private
      #
      def delete
        mapper.delete(self)
      end

      # Return dirty state
      #
      # @return [State::Dirty]
      #
      # @api private
      #
      def dirty
        Dirty.new(self)
      end

      # Persist changes to wrapped domain object
      #
      # Noop when not dirty.
      #
      # @return [self]
      #
      # @api private
      #
      def persist
        dirty.persist
      end

    end
  end
end
