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
        response = left.call(*args)

        if result == :one
          if right.is_a?(Command) || right.is_a?(Commands::Composite)
            right.call([response].first)
          else
            right.call([response]).first
          end
        else
          right.call(response)
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

      # @api private
      def respond_to_missing?(name, include_private = false)
        left.respond_to?(name) || super
      end

      private

      # Allow calling methods on the left side object
      #
      # @api private
      def method_missing(name, *args, &block)
        if left.respond_to?(name)
          response = left.__send__(name, *args, &block)
          if response.is_a?(left.class)
            self.class.new(response, right)
          else
            response
          end
        else
          super
        end
      end
    end
  end
end
