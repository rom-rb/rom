# frozen_string_literal: true

require 'dry/equalizer'

require 'rom/types'
require 'rom/initializer'
require 'rom/pipeline'
require 'rom/relation/name'
require 'rom/relation/materializable'

module ROM
  class Relation
    # Curried relation is a special relation proxy used by auto-curry mechanism.
    #
    # When a relation view method is called without all arguments, a curried proxy
    # is returned that can be fully applied later on.
    #
    # Curried relations are typically used for relation composition
    #
    # @api public
    class Curried
      extend Initializer

      include Dry::Equalizer(:relation, :options)
      include Materializable
      include Pipeline

      undef :map_with

      # @!attribute [r] relation
      #   @return [Relation] The source relation that is curried
      param :relation

      # @!attribute [r] view
      #   @return [Symbol] The name of relation's view method
      option :view, type: Types::Strict::Symbol

      # @!attribute [r] arity
      #   @return [Integer] View's arity
      option :arity, type: Types::Strict::Integer

      # @!attribute [r] curry_args
      #   @return [Array] Arguments that will be passed to curried view
      option :curry_args, default: -> { EMPTY_ARRAY }

      # Load relation if args match the arity
      #
      # @return [Loaded,Curried]
      #
      # @api public
      def call(*args)
        all_args = curry_args + args

        if all_args.empty?
          raise ArgumentError, "curried #{relation.class}##{view} relation was called without any arguments"
        end

        if args.empty?
          self
        elsif arity == all_args.size
          Loaded.new(relation.__send__(view, *all_args))
        else
          __new__(relation, curry_args: all_args)
        end
      end
      alias_method :[], :call

      # Relations are coercible to an array but a curried relation cannot be coerced
      # When something tries to do this, an exception will be raised
      #
      # @raise ArgumentError
      #
      # @api public
      def to_a
        raise(
          ArgumentError,
          "#{relation.class}##{view} arity is #{arity} " \
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
      def __new__(relation, new_opts = EMPTY_HASH)
        self.class.new(relation, new_opts.empty? ? options : options.merge(new_opts))
      end

      # @api private
      def composite_class
        Relation::Composite
      end

      # @api private
      def method_missing(meth, *args, &block)
        if relation.respond_to?(meth)
          response = relation.__send__(meth, *args, &block)

          super if response.is_a?(self.class)

          if response.is_a?(Relation) || response.is_a?(Graph) || response.is_a?(Wrap) || response.is_a?(Composite)
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
