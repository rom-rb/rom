module DataMapper
  class Session
    class State
      # State for loaded objects
      class Loading < self

        # Return identity
        #
        # @return [Identity]
        #
        # @api private
        #
        def identity
          loader.identity
        end

        # Return object
        #
        # @return [Object]
        #
        # @api private
        #
        def object
          loader.object
        end

        # Return loaded state
        #
        # @return [State::Loaded]
        #
        # @api private
        #
        def loaded
          Loaded.new(self)
        end

      private

        # Return loader
        #
        # @return [Loader]
        #
        # @api private
        #
        def loader
          @mapper.loader(@tuple)
        end
        memoize :loader, :freezer => :noop

        # Initialize object
        #
        # @param [Mapper] mapper
        # @param [Object] tuple
        #
        # @return [undefined]
        #
        # @api private
        #
        def initialize(mapper, tuple)
          @mapper, @tuple = mapper, tuple
        end
      end
    end
  end
end
