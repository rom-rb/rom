require 'rom/relation/loaded'

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

    class Lazy
      include Equalizer.new(:relation, :options)

      include Options

      option :name, type: Symbol, reader: true
      option :arity, type: Integer, reader: true, default: -1
      option :curry_args, type: Array, reader: true, default: EMPTY_ARRAY
      option :mappers, reader: true, default: EMPTY_HASH

      attr_reader :relation, :arity

      def initialize(relation, options = {})
        super
        @relation = relation
      end

      def >>(other)
        Composite.new(self, other)
      end

      def map_with(*names)
        [self, *names.map { |name| mappers[name] }]
          .reduce { |a, e| Composite.new(a, e) }
      end
      alias_method :as, :map_with

      def to_a
        call.to_a
      end
      alias_method :to_ary, :to_a

      def call(*args)
        if arity != -1
          all_args = curry_args + args

          if arity == all_args.size
            Loaded.new(relation.__send__(name, *all_args), mappers)
          else
            __new__(relation, curry_args: all_args)
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

      def method_missing(meth, *args, &block)
        if !relation.respond_to?(meth) || (name && meth != name)
          super
        else
          arity = relation.method(meth).arity

          if arity == -1 || arity == args.size
            __new__(relation.__send__(meth, *args, &block))
          else
            __new__(
              relation,
              name: meth, curry_args: args, arity: arity
            )
          end
        end
      end

      def __new__(relation, new_opts = {})
        self.class.new(relation, options.merge(new_opts))
      end
    end
  end
end
