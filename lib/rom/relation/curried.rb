require 'rom/relation/lazy'

module ROM
  class Relation
    class Curried < Lazy
      option :name, type: Symbol, reader: true
      option :arity, type: Integer, reader: true, default: -1
      option :curry_args, type: Array, reader: true, default: EMPTY_ARRAY

      def call(*args)
        if arity != -1
          all_args = curry_args + args

          if arity == all_args.size
            Loaded.new(relation.__send__(name, *all_args), mappers)
          else
            __new__(relation, curry_args: all_args)
          end
        else
          super
        end
      end
      alias_method :[], :call

      def curried?
        true
      end
    end
  end
end
