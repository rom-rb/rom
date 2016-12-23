require 'rom/support/options'

require 'rom/pipeline'
require 'rom/relation/name'
require 'rom/relation/materializable'

module ROM
  class Relation
    class Curried
      include Options
      include Materializable
      include Pipeline

      option :name, type: Symbol
      option :arity, type: Integer, reader: true, default: -1
      option :curry_args, type: Array, reader: true, default: EMPTY_ARRAY

      attr_reader :relation

      attr_reader :name

      # @api private
      def initialize(relation, options = EMPTY_HASH)
        @relation = relation
        @name = relation.name.with(options[:name])
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
            Loaded.new(relation.__send__(name.relation, *all_args))
          else
            new(relation, curry_args: all_args)
          end
        else
          super
        end
      end
      alias_method :[], :call

      # @api public
      def new(relation, new_opts = EMPTY_HASH)
        Curried.new(relation, new_opts.empty? ? options : options.merge(new_opts))
      end

      # @api public
      def to_a
        raise(
          ArgumentError,
          "#{relation.class}##{name.relation} arity is #{arity} " \
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
        super || relation.respond_to?(name, include_private)
      end

      private

      # @api private
      def composite_class
        Relation::Composite
      end

      # @api private
      def method_missing(meth, *args, &block)
        if relation.respond_to?(meth)
          response = relation.__send__(meth, *args, &block)

          super if response.is_a?(self.class)

          if response.is_a?(Relation) || response.is_a?(Graph)
            new(response)
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
