# encoding: utf-8

module ROM
  class Session

    # @api private
    class State
      include Adamantium::Flat
      include Concord::Public.new(:object, :relation)

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
      def update(*)
        raise TransitionError, "cannot update object with #{self.class} state"
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

      # @api private
      def identity
        relation.identity(object)
      end
    end # State

  end # Session
end # ROM
