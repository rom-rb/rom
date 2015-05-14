require 'rom/relation/loaded'

module ROM
  class Relation
    # Left-to-right relation composition used for data-pipelining
    #
    # @api public
    class Composite
      include Equalizer.new(:left, :right)

      # @return [Lazy,Curried,Composite,#call]
      #
      # @api private
      attr_reader :left

      # @return [Lazy,Curried,Composite,#call]
      #
      # @api private
      attr_reader :right

      # @api private
      def initialize(left, right)
        @left = left
        @right = right
      end

      # Compose with another callable object
      #
      # @param [#call]
      #
      # @return [Composite]
      #
      # @api public
      def >>(other)
        self.class.new(self, other)
      end

      # Call the pipeline by passing results from left to right
      #
      # Optional args are passed to the left object
      #
      # @return [Loaded]
      #
      # @api public
      def call(*args)
        relation = left.call(*args)
        response = right.call(relation)

        if relation.is_a?(Loaded)
          relation.new(response)
        else
          Loaded.new(relation, response)
        end
      end
      alias_method :[], :call

      # Coerce composite relation to an array
      #
      # @return [Array]
      #
      # @api public
      def to_a
        call.to_a
      end
      alias_method :to_ary, :to_a

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

      # Yield composite relation objects
      #
      # @yield [Object]
      #
      # @api public
      def each(&block)
        return to_enum unless block
        call.each { |object| yield(object) }
      end

      # Return first object from the called relation
      #
      # @return [Object]
      #
      # @api public
      def first
        call.first
      end

      # @api private
      def respond_to_missing?(name, include_private = false)
        left.respond_to?(name) || super
      end

      private

      # Allow calling methods on the left side object
      #
      # @api private
      def method_missing(name, *args, &block)
        if left.respond_to?(name)
          response = left.__send__(name, *args, &block)
          if response.is_a?(left.class) || response.is_a?(Graph)
            self.class.new(response, right)
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
