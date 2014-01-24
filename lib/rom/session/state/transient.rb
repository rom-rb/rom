# encoding: utf-8

module ROM
  class Session
    class State

      # @api private
      class Transient < self
        include Concord::Public.new(:object, :mapper)

        # @api private
        def save(relation)
          Created.new(object, mapper, relation)
        end

      end # Transient

    end # State
  end # Session
end # ROM
