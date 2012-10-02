module Session
  class State
    # State for dumps that are loaded
    class Loading < State

      # Return mapper
      #
      # @return [Mapper]
      #
      # @api private
      #
      attr_reader :mapper

      # Return key
      #
      # @return [Object]
      #
      # @api private
      #
      def key
        mapper.load_key(dump)
      end
      memoize :key

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
      memoize :load

      # Return object
      #
      # @return [Object]
      #
      # @api private
      #
      def object
        mapper.load(dump)
      end
      memoize :object

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
