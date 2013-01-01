module DataMapper
  class Session

    # A class to read objects via identity map
    class Reader
      include Equalizer.new(:session, :reader)

      # Return mapper
      #
      # @return [Mapper]
      #
      # @api private
      #
      attr_reader :mapper

      # Return mapper
      #
      # @return [Session]
      #
      # @api private
      #
      attr_reader :session

      # Load object
      #
      # @param [Object] tuple
      #
      # @return [Object]
      #
      # @api private
      #
      def load(tuple)
        @session.load(mapper.loader(tuple))
      end

    private

      # Initialize object
      #
      # @param [Session] session
      # @param [Mapper] mapper
      #
      # @return [undefined]
      #
      def initialize(session, mapper)
        @session, @mapper = session, mapper
      end

    end
  end
end
