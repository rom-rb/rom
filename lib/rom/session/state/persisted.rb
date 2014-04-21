# encoding: utf-8

module ROM
  class Session
    class State

      # @api private
      class Persisted < self

        # @api private
        def save
          if relation.dirty?(object)
            Updated.new(object, relation)
          else
            self
          end
        end

        # @api private
        def update(tuple)
          Updated.new(object.update(tuple), relation)
        end

        # @api private
        def delete
          Deleted.new(object, relation)
        end

      end # Persisted

    end # State
  end # Session
end # ROM
