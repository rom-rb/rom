require 'rom/relation/loaded'
require 'rom/relation/composite'

module ROM
  class Relation
    # Lazy relation wraps canonical relation for data-pipelining
    #
    # @example
    #   ROM.setup(:memory)
    #
    #   class Users < ROM::Relation[:memory]
    #     def by_name(name)
    #       restrict(name: name)
    #     end
    #   end
    #
    #   rom = ROM.finalize.env
    #
    #   rom.relations.users << { name: 'Jane' }
    #   rom.relations.users << { name: 'Joe' }
    #
    #   mapper = proc { |users| users.map { |user| user[:name] } }
    #   users = rom.relation(:users)
    #
    #   (users.by_name >> mapper)['Jane'].inspect # => ["Jane"]
    #
    # @api public
    class Lazy
      include Equalizer.new(:relation, :options)
      include Options

      option :mappers, reader: true, default: EMPTY_HASH

      # @return [Relation]
      #
      # @api private
      attr_reader :relation

      # Map of exposed relation methods
      #
      # @return [Hash<Symbol=>TrueClass>]
      #
      # @api private
      attr_reader :methods

      # @api private
      def initialize(relation, options = {})
        super
        @relation = relation
        @methods = @relation.exposed_relations
      end

      # Compose two relation with a left-to-right composition
      #
      # @example
      #   users.by_name('Jane') >> tasks.for_users
      #
      # @param [Relation] other The right relation
      #
      # @return [Relation::Composite]
      #
      # @api public
      def >>(other)
        Composite.new(self, other)
      end

      # Build a relation pipeline using registered mappers
      #
      # @example
      #   rom.relation(:users).map_with(:json_serializer)
      #
      # @return [Relation::Composite]
      #
      # @api public
      def map_with(*names)
        [self, *names.map { |name| mappers[name] }]
          .reduce { |a, e| Composite.new(a, e) }
      end
      alias_method :as, :map_with

      # Coerce lazy relation to an array
      #
      # @return [Array]
      #
      # @api public
      def to_a
        call.to_a
      end
      alias_method :to_ary, :to_a

      # Load relation
      #
      # @return [Relation::Loaded]
      #
      # @api public
      def call
        Loaded.new(relation)
      end
      alias_method :[], :call

      # Yield relation tuples
      #
      # @yield [Object]
      #
      # @api public
      def each(&block)
        return to_enum unless block
        to_a.each { |tuple| yield(tuple) }
      end

      # Delegate to loaded relation and return one object
      #
      # @return [Object]
      #
      # @see Loaded#one
      #
      # @api public
      def one
        call.one
      end

      # Delegate to loaded relation and return one object
      #
      # @return [Object]
      #
      # @see Loaded#one
      #
      # @api public
      def one!
        call.one!
      end

      # @api private
      def respond_to_missing?(name, include_private = false)
        methods.include?(name) || super
      end

      # Return if this lazy relation is curried
      #
      # @return [false]
      #
      # @api private
      def curried?
        false
      end

      private

      # Forward methods to the underlaying relation
      #
      # Auto-curry relations when args size doesn't match arity
      #
      # @return [Lazy,Curried]
      #
      # @api private
      def method_missing(meth, *args, &block)
        if !methods.include?(meth) || (curried? && name != meth)
          super
        else
          arity = relation.method(meth).arity

          if arity == -1 || arity == args.size
            response = relation.__send__(meth, *args, &block)
            if response.is_a?(Relation)
              __new__(response)
            else
              response
            end
          else
            Curried.new(relation, name: meth, curry_args: args, arity: arity)
          end
        end
      end

      # Return new lazy relation with updated options
      #
      # @api private
      def __new__(relation, new_opts = {})
        Lazy.new(relation, options.merge(new_opts))
      end
    end
  end
end
