module DataMapper
  class Session

    # A class to read objects via identity map
    class Reader
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
      # @param [Object] body
      #
      # @return [Object]
      #
      # @api private
      #
      def load(body)
        @session.load(mapper, body)
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
