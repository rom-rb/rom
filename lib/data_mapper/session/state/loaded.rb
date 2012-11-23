module DataMapper
  class Session
    class State
      # An State that represents a loaded domain object.
      class Loaded < self

        # Test if mapping is dirty
        #
        # @param [Mapping] mapping
        #
        # @return [true]
        #   if object is dirty
        #
        # @return [false]
        #   otherwise
        #
        # @api private
        #
        def dirty?(mapping)
          !dirty(mapping).clean?
        end

        # Delete object via mapper
        #
        # @return [self]
        #
        # @api private
        #
        def delete
          mapper.delete(Operand.new(self))
          self
        end

        # Return dirty state
        #
        # @param [Mapping] mapping
        #
        # @return [State::Dirty]
        #
        # @api private
        #
        def dirty(mapping)
          Dirty.new(mapping, self)
        end

        # Persist changes 
        #
        # @param [Mapping] mapping
        #
        # @return [self]
        #   when not dirty
        #
        # @return [State::Loaded]
        #   when dirty
        #
        # @api private
        #
        def persist(mapping)
          dirty(mapping).persist
          self
        end

      end
    end
  end
end
