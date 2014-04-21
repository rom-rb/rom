# encoding: utf-8

module ROM
  class Session
    class State

      # @api private
      class Updated < self

        # @api private
        def commit
          Persisted.new(object, relation.update!(object, original_tuple))
        end

        private

        # @api private
        def original_tuple
          relation.identity_map.fetch_tuple(relation.identity(object))
        end

      end # Updated

    end # State
  end # Session
end # ROM
