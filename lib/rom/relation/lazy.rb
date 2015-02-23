require 'rom/relation/loaded'
require 'rom/relation/composite'

module ROM
  class Relation
    class Lazy
      include Equalizer.new(:relation, :options)
      include Options

      option :mappers, reader: true, default: EMPTY_HASH

      attr_reader :relation

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
        Loaded.new(relation, mappers)
      end
      alias_method :[], :call

      def respond_to_missing?(name, include_private = false)
        relation.respond_to?(name) || super
      end

      def curried?
        false
      end

      private

      def method_missing(meth, *args, &block)
        if !relation.respond_to?(meth) || (curried? && name != meth)
          super
        else
          arity = relation.method(meth).arity

          if arity == -1 || arity == args.size
            __new__(relation.__send__(meth, *args, &block))
          else
            Curried.new(relation, name: meth, curry_args: args, arity: arity)
          end
        end
      end

      def __new__(relation, new_opts = {})
        Lazy.new(relation, options.merge(new_opts))
      end
    end
  end
end
