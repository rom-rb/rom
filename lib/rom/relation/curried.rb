require 'rom/relation/lazy'

module ROM
  class Relation
    class Curried < Lazy
      option :name, type: Symbol, reader: true
      option :arity, type: Integer, reader: true, default: -1
      option :curry_args, type: Array, reader: true, default: EMPTY_ARRAY

      # Load relation if args match the arity
      #
      # @return [Loaded,Lazy,Curried]
      # @see Lazy#call
      #
      # @api public
      def call(*args)
        if arity != -1
          all_args = curry_args + args

          if arity == all_args.size
            Loaded.new(relation.__send__(name, *all_args))
          else
            __new__(relation, curry_args: all_args)
          end
        else
          super
        end
      end
      alias_method :[], :call

      # Return if this lazy relation is curried
      #
      # @return [true]
      #
      # @api private
      def curried?
        true
      end

      private

      # @api private
      def __new__(relation, new_opts = {})
        Curried.new(relation, options.update(new_opts))
      end
    end
  end
end
