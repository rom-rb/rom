require 'rom/relation/loaded'

module ROM
  class Relation
    class Composite
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

    class Lazy
      include Options

      option :name, type: Symbol, reader: true
      option :curry_args, type: Array, reader: true
      option :mappers, reader: true, default: EMPTY_HASH

      attr_reader :relation, :method

      def initialize(relation, options = {})
        super
        @relation = relation
        @method = relation.method(name) if name
      end

      def >>(other)
        Composite.new(self, other)
      end

      def map_with(*names)
        [self, *names.map { |name| mappers[name] }]
          .reduce { |l, r| Composite.new(l, r) }
      end
      alias_method :as, :map_with

      def to_a
        call.to_a
      end
      alias_method :to_ary, :to_a

      def call(*args)
        if name
          all_args = curry_args + args

          if method.arity == all_args.size
            Loaded.new(relation.__send__(name, *all_args), mappers)
          else
            self.class.new(relation, options.merge(name: name, curry_args: all_args))
          end
        else
          Loaded.new(relation, mappers)
        end
      end
      alias_method :[], :call

      def respond_to_missing?(name, include_private = false)
        relation.respond_to?(name) || super
      end

      private

      def method_missing(name, *args)
        self.class.new(relation, options.merge(name: name, curry_args: args))
      end
    end
  end
end
