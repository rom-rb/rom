# encoding: utf-8

module ROM
  class Session
    class State

      # @api private
      class Deleted < self
        include Adamantium::Flat

        class Committed < State
          include Adamantium::Flat
        end

        # @api private
        def commit
          Committed.new(object, relation.delete!(object))
        end

      end # Deleted

    end # State
  end # Session
end # ROM
