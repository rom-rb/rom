module DataMapper
  class AliasSet

    class Joined
      include Enumerable

      # @api private
      attr_reader :left

      # @api private
      attr_reader :right

      # @api private
      def initialize(left, right)
        @left  = left
        @right = right
      end

      # @api private
      def each(&block)
        return to_enum unless block_given?
        to_a.each(&block)
        self
      end

      # @api private
      def join(other)
        self.class.new(self, other)
      end

      # @api private
      def to_a
        [ left.to_a, right.to_a ].flatten
      end

    end # class Joined

  end # class AliasSet
end # module DataMapper
