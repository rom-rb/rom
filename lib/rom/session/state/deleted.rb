# encoding: utf-8

module ROM
  class Session
    class State

      # @api private
      class Deleted < self
        include Concord::Public.new(:object, :relation), Adamantium::Flat

        class Committed < State
          include Adamantium
        end

        # @api private
        def commit
          relation.delete(object)
          Committed.new(object)
        end

      end # Deleted

    end # State
  end # Session
end # ROM
