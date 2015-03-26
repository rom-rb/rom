module ROM
  module Commands
    # Composite command that consists of left and right commands
    #
    # @api public
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
        if result == :one
          if right.is_a?(Command)
            right.call([left.call(*args)].first)
          else
            right.call([left.call(*args)]).first
          end
        else
          right.call(left.call(*args))
        end
      end
      alias_method :[], :call

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

      # @api private
      def result
        left.result
      end
    end
  end
end
