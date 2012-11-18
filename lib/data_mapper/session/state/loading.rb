module DataMapper
  class Session
    class State
      # State for dumps that are loaded
      class Loading < self
        include Equalizer.new(:mapper, :raw_dump)

        # Return loader
        #
        # @return [Loader]
        #
        # @api private
        #
        def loader
          mapper.loader(@raw_dump)
        end
        memoize :loader

        abstract_method :mapping

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
          loader.body
        end

        # Return dump
        #
        # @return [Dump]
        #
        # @api private
        #
        def dump
          Dump.new(loader)
        end

        # Return model
        #
        # @return [Model]
        #
        # @api private
        #
        def model
          mapper.model
        end

        # Return key
        #
        # @return [Object]
        #
        # @api private
        #
        def key
          loader.key
        end

        # Return mapper
        #
        # @return [Mapper]
        #
        # @api private
        #
        attr_reader :mapper

        # Return raw dump
        #
        # @return [Object]
        #
        # @api private
        #
        attr_reader :raw_dump

      private

        # Initialize object
        #
        # @param [Mapper] mapper
        # @param [Object] raw_dump
        #
        # @return [undefined]
        #
        # @api private
        #
        def initialize(mapper, raw_dump)
          @mapper, @raw_dump = mapper, raw_dump
        end

      end
    end
  end
end
