module DataMapper
  class Session
    class State
      # State for dumps that are loaded
      class Loading < self

        # Return mapper
        #
        # @return [Mapper]
        #
        # @api private
        #
        attr_reader :mapper

        # Return loader
        #
        # @return [Loader]
        #
        # @api private
        #
        def loader
          mapper.loader(dump)
        end
        memoize :loader

        # Return mapping
        #
        # @return [Mapping]
        #
        # @api private
        #
        def mapping
          Mapping.new(mapper, object)
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

        # Return object
        #
        # @return [Object]
        #
        # @api private
        #
        def object
          loader.object
        end

      private

        # Initialize object
        #
        # @param [Mapper] mapper
        # @param [Object] dump
        #
        # @return [undefined]
        #
        # @api private
        #
        def initialize(mapper, dump)
          @mapper, @dump = mapper, dump
        end
      end
    end
  end
end
