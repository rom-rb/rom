module ROM
  class Session

    # A class to read objects via the identity map
    class Reader
      include Equalizer.new(:session, :reader)

      # Return mapper
      #
      # @return [Mapper]
      #
      # @api private
      attr_reader :mapper

      # Return session
      #
      # @return [Session]
      #
      # @api private
      attr_reader :session

      # Load object from +tuple+
      #
      # @param [#[]] tuple
      #   the tuple used to load an object
      #
      # @return [Object]
      #   a domain model instance
      #
      # @api private
      def load(tuple)
        @session.load(mapper.loader(tuple))
      end

    private

      # Initialize object
      #
      # @param [Session] session
      #   the session instance to use
      #
      # @param [Mapper] mapper
      #   the mapper instance to use
      #
      # @return [undefined]
      #
      # @api private
      def initialize(session, mapper)
        @session, @mapper = session, mapper
      end

    end
  end
end
