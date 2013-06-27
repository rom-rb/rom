module ROM
  class Session
    class State

      # @api private
      class Transient < self
        include Concord::Public.new(:object)

        # @api private
        def save(relation)
          Created.new(object, relation)
        end

      end # Transient

    end # State
  end # Session
end # ROM
