module ROM
  module Commands
    class Composite
      include Equalizer.new(:left, :right)

      attr_reader :left, :right

      def initialize(left, right)
        @left, @right = left, right
      end

      def call(*args)
        right.call(left.call(*args))
      end

      def >>(other)
        self.class.new(self, other)
      end
    end
  end
end
