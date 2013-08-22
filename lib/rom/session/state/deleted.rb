# encoding: utf-8

module ROM
  class Session
    class State

      # @api private
      class Deleted < self
        include Concord::Public.new(:object, :relation), Adamantium::Flat

        Committed = Class.new(State) { include Adamantium }

        # @api private
        def commit
          relation.delete(object)
          Committed.new(object)
        end

      end # Deleted

    end # State
  end # Session
end # ROM
