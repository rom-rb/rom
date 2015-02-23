module ROM
  class Relation
    class Composite
      include Equalizer.new(:left, :right)

      attr_reader :left, :right

      def initialize(left, right)
        @left = left
        @right = right
      end

      def >>(other)
        self.class.new(self, other)
      end

      def call(*args)
        right.call(left.call(*args))
      end
      alias_method :[], :call

      def to_a
        [left.to_a, call.to_a]
      end

      def respond_to_missing?(name, include_private = false)
        left.respond_to?(name) || super
      end

      private

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
