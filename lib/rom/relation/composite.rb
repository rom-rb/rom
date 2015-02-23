module ROM
  class Relation
    # Left-to-right relation composition used for data-pipelining
    #
    # @api public
    class Composite
      include Equalizer.new(:left, :right)

      # @return [Lazy,Curried,Composite,#call]
      #
      # @api private
      attr_reader :left

      # @return [Lazy,Curried,Composite,#call]
      #
      # @api private
      attr_reader :right

      # @api private
      def initialize(left, right)
        @left = left
        @right = right
      end

      # Compose with another callable object
      #
      # @param [#call]
      #
      # @return [Composite]
      #
      # @api public
      def >>(other)
        self.class.new(self, other)
      end

      # Call the pipeline by passing results from left to right
      #
      # Optional args are passed to the left object
      #
      # @return [Array]
      #
      # @alias []
      #
      # @api public
      def call(*args)
        right.call(left.call(*args))
      end
      alias_method :[], :call

      # Return results from the left and the composite result
      #
      # @return [Array<Array>]
      #
      # @api private
      def to_a
        [left.to_a, call.to_a]
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
          self.class.new(left.__send__(name, *args, &block), right)
        else
          super
        end
      end
    end
  end
end
