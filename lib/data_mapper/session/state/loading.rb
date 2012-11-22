module DataMapper
  class Session
    class State
      # State for dumps that are loaded
      class Loading < self

        # Return mapping
        #
        # @return [Mapping]
        #
        # @api private
        #
        def mapping
          Mapping.new(@mapper, loader.body)
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
          @mapper.loader(@dump)
        end
        memoize :loader

        # Initialize object
        #
        # @param [Mapper] mapper
        # @param [Object] raw_dump
        #
        # @return [undefined]
        #
        # @api private
        #
        def initialize(mapper, dump)
          @loader = mapper.loader(dump)
          @mapper, @dump = mapper, dump
        end
      end
    end
  end
end
