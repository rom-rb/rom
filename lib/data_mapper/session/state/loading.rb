module DataMapper
  class Session
    class State
      # State for loaded objects
      class Loading < self

        # Return mapping
        #
        # @return [Mapping]
        #
        # @api private
        #
        def mapping
          Mapping.new(@mapper, loader.object)
        end
        memoize :mapping

        # Return loaded state
        #
        # @return [State::Loaded]
        #
        # @api private
        #
        def loaded
          Loaded.new(self)
        end
        memoize :loaded

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
        memoize :loader

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
          @loader = mapper.loader(tuple)
          @mapper, @tuple = mapper, tuple
        end
      end
    end
  end
end
