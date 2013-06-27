module ROM
  class Session

    # @api private
    class State
      include Concord::Public.new(:object)

      TransitionError = Class.new(StandardError)

      # @api private
      def save(*)
        raise TransitionError, "cannot save object with #{self.class} state"
      end

      # @api private
      def delete(*)
        raise TransitionError, "cannot delete object with #{self.class} state"
      end

      # @api private
      def transient?
        instance_of?(Transient)
      end

      # @api private
      def created?
        instance_of?(Created)
      end

      # @api private
      def persisted?
        instance_of?(Persisted)
      end

      # @api private
      def updated?
        instance_of?(Updated)
      end

      # @api private
      def deleted?
        instance_of?(Deleted)
      end

    end # State

  end # Session
end # ROM
