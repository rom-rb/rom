# encoding: utf-8

module ROM
  class Session
    class State

      # @api private
      class Transient < self

        # @api private
        def save
          Created.new(object, relation)
        end

      end # Transient

    end # State
  end # Session
end # ROM
