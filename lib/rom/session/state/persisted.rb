module ROM
  class Session
    class State

      # @api private
      class Persisted < self
        include Concord::Public.new(:object, :mapper)

        # @api private
        def save(relation)
          if mapper.dirty?(object)
            Updated.new(object, original_tuple, relation)
          else
            self
          end
        end

        # @api private
        def delete(relation)
          Deleted.new(object, relation)
        end

        private

        # @api private
        def original_tuple
          mapper.identity_map.fetch_tuple(mapper.identity(object))
        end

      end # Persisted

    end # State
  end # Session
end # ROM
