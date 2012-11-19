module DataMapper
  class Session
    # Represent dumped domain object
    class Dump
      include Adamantium, Equalizer.new(:identity, :body)

      # Return identity
      #
      # @return [Object]
      #
      # @api private
      #
      attr_reader :identity

      # Return body
      #
      # @return [Object]
      #
      # @api private
      #
      attr_reader :body

    private

      # Initialize object
      #
      # @param [Dumper, Loader] input
      #
      # @return [undefined]
      #
      # @api private
      #
      def initialize(input)
        @identity, @body = input.identity, input.body
      end
    end
  end
end
