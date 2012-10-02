module Session
  class State
    # An State that represents a loaded domain object.
    class Loaded < self

      # Invoke transition to forgotten object state
      #
      # @return [State::Forgotten]
      #
      # @api private
      #
      def forget
        Forgotten.new(self)
      end

      # Invoke transition to forgotten object state after deleting via mapper
      #
      # @return [State::Forgotten]
      #
      # @api private
      #
      def delete
        mapper.delete(self)

        forget
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
