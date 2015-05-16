module ROM
  # Data pipeline common interface
  #
  # @api private
  module Pipeline
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
      Relation::Composite.new(self, other)
    end

    # Send data through specified mappers
    #
    # @return [Relation::Composite]
    #
    # @api public
    def map_with(*names)
      [self, *names.map { |name| mappers[name] }]
        .reduce { |a, e| Relation::Composite.new(a, e) }
    end
    alias_method :as, :map_with

    # Forwards messages to the left side of a pipeline
    #
    # @api private
    module Proxy
      # @api private
      def respond_to_missing?(name, include_private = false)
        left.respond_to?(name) || super
      end

      private

      # Check if response from method missing should be decorated
      #
      # @api private
      def decorate?(response)
        response.is_a?(left.class)
      end

      # @api private
      def method_missing(name, *args, &block)
        if left.respond_to?(name)
          response = left.__send__(name, *args, &block)

          if decorate?(response)
            self.class.new(response, right)
          else
            response
          end
        else
          super
        end
      end
    end

    # Base composite class with left-to-right pipeline behavior
    #
    # @api private
    class Composite
      include Equalizer.new(:left, :right)
      include Proxy

      # @api private
      attr_reader :left

      # @api private
      attr_reader :right

      # @api private
      def initialize(left, right)
        @left, @right = left, right
      end

      # Compose this composite with another object
      #
      # @api public
      def >>(other)
        self.class.new(self, other)
      end
    end
  end
end
