module ROM
  class Session
    class State

      # @api private
      class Persisted < self
        include Concord::Public.new(:object, :mapper)

        # @api private
        def save(relation)
          if mapper.dirty?(object)
            Updated.new(object, relation)
          else
            self
          end
        end

        # @api private
        def delete(relation)
          Deleted.new(object, relation)
        end

      end # Persisted

    end # State
  end # Session
end # ROM
