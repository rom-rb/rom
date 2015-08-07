require 'rom/support/options'
require 'rom/relation/materializable'

module ROM
  class Relation
    class Curried
      include Options
      include Materializable

      option :name, type: Symbol, reader: true
      option :arity, type: Integer, reader: true, default: -1
      option :curry_args, type: Array, reader: true, default: EMPTY_ARRAY

      attr_reader :relation

      # @api private
      def initialize(relation, options = {})
        @relation = relation
        super
      end

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

      # @api public
      def to_a
        raise(
          ArgumentError,
          "#{relation.class}##{name} arity is #{arity} " \
          "(#{curry_args.size} args given)"
        )
      end
      alias_method :to_ary, :to_a

      # Return if this lazy relation is curried
      #
      # @return [true]
      #
      # @api private
      def curried?
        true
      end

      # @api private
      def respond_to_missing?(name, include_private = false)
        super || relation.respond_to?(name)
      end

      private

      # @api private
      def __new__(relation, new_opts = {})
        Curried.new(relation, options.merge(new_opts))
      end

      # @api private
      def method_missing(meth, *args, &block)
        if relation.respond_to?(meth)
          response = relation.__send__(meth, *args, &block)

          if response.is_a?(Relation) || response.is_a?(Graph)
            __new__(response)
          else
            response
          end
        else
          super
        end
      end
    end
  end
end
