module ROM
  module Commands
    # Composite command that consists of left and right commands
    #
    # @public
    class Composite
      include Equalizer.new(:left, :right)

      # @return [Proc,Command] left command
      #
      # @api private
      attr_reader :left

      # @return [Proc,Command] right command
      #
      # @api private
      attr_reader :right

      # @api private
      def initialize(left, right)
        @left, @right = left, right
      end

      # Calls the composite command
      #
      # Right command is called with a result from the left one
      #
      # @return [Object]
      #
      # @api public
      def call(*args)
        right.call(left.call(*args))
      end

      # Compose another composite command from self and other
      #
      # @param [Proc, Command] other command
      #
      # @return [Composite]
      #
      # @api public
      def >>(other)
        self.class.new(self, other)
      end
    end
  end
end
