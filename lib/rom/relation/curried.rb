require 'rom/types'
require 'rom/initializer'
require 'rom/pipeline'
require 'rom/relation/name'
require 'rom/relation/materializable'

module ROM
  class Relation
    class Curried
      extend Initializer
      include Materializable
      include Pipeline

      param :relation

      option :name, optional: true, type: Types::Strict::Symbol
      option :arity, type: Types::Strict::Int, reader: true, default: -> { -1 }
      option :curry_args, reader: true, default: -> { EMPTY_ARRAY }

      # Relation name
      #
      # @return [ROM::Relation::Name]
      #
      # @api public
      def name
        @name == Dry::Initializer::UNDEFINED ? relation.name : relation.name.with(@name)
      end

      # Load relation if args match the arity
      #
      # @return [Loaded,Curried]
      #
      # @api public
      def call(*args)
        if arity != -1
          all_args = curry_args + args

          if all_args.empty?
            raise ArgumentError, "curried #{relation.class}##{name.to_sym} relation was called without any arguments"
          end

          if args.empty?
            self
          elsif arity == all_args.size
            Loaded.new(relation.__send__(name.relation, *all_args))
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
