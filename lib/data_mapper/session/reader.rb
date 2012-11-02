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

      # Return mapper
      #
      # @return [Query]
      #
      # @api private
      #
      attr_reader :query

    private

      # Initialize object
      #
      # @param [Session] session
      # @param [Mapper] mapper
      # @param [Query] query
      #
      # @return [undefined]
      #
      def initialize(session, mapper, query)
        @session, @mapper, @query = session, mapper, query
      end

      # Enumerate objects
      #
      # @return [self]
      #   if block given
      #
      # @return [Enumerator<Object>]
      #   otherwise
      #
      # @api private
      #
      def each
        return to_enum unless block_given?

        bodies.each do |body|
          yield load(body)
        end
      end

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

      # Enumerate dumps
      #
      # @return [self]
      #   if block given
      #
      # @return [Enumerator<Object>]
      #   otherwise
      #
      # @api private
      #
      def bodies
        return to_enum(__method__) unless block_given?
        @mapper.read(query) do |body|
          yield body
        end
        self
      end
    end
  end
end
