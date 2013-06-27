module ROM
  class Session
    class State

      # @api private
      class Deleted < self
        include Concord::Public.new(:object, :relation), Adamantium::Flat

        Commited = Class.new(self)

        # @api private
        def commit
          Commited.new(object, relation.delete(object))
        end

      end # Deleted

    end # State
  end # Session
end # ROM
