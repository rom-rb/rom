module DataMapper
  class Session
    # Represent dumped domain object
    class Dump
      include Adamantium, Equalizer.new(:key, :body)

      # Return key
      #
      # @return [Object]
      #
      # @api private
      #
      attr_reader :key

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
        @key, @body = input.key, input.body
      end
    end
  end
end
