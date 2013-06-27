module ROM
  class Session
    class State

      # @api private
      class Updated < self
        include Concord::Public.new(:object, :relation)

        Commited = Class.new(self)

        # @api private
        def commit
          Commited.new(object, relation.update(object))
        end

      end # Updated

    end # State
  end # Session
end # ROM
