module ROM
  class Relation
    class Composite
      attr_reader :left, :right

      def initialize(left, right)
        @left = left
        @right = right
      end

      def call
        right.call(left.call)
      end

      def to_a
        [left.to_a, call.to_a]
      end
    end

    class Lazy
      include Options

      option :name, type: Symbol, reader: true
      option :curry_args, type: Array, reader: true

      attr_reader :relation, :method

      def initialize(relation, options = {})
        super
        @relation = relation
        @method = relation.method(name) if name
      end

      def >>(other)
        Composite.new(self, other)
      end

      def to_a
        call.to_a
      end

      def call(*args)
        if name
          all_args = curry_args + args

          if method.arity == curry_args.size
            relation.__send__(name, *all_args)
          else
            self.class.new(relation, name: name, curry_args: all_args)
          end
        else
          relation
        end
      end
      alias_method :[], :call

      private

      def method_missing(name, *args)
        self.class.new(relation, name: name, curry_args: args)
      end
    end
  end
end
