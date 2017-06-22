module ROM
  # @api private
  module Memoizable
    module ClassInterface
      # @api private
      def memoize(*names)
        prepend(Memoizer.new(names))
      end
    end

    def self.included(klass)
      super
      klass.extend(ClassInterface)
    end

    # @api private
    def __memoized__
      @__memoized__ ||= {}
    end

    # @api private
    class Memoizer < Module
      attr_reader :names

      # @api private
      def initialize(names)
        @names = names
        define_memoizable_names!
      end

      private

      # @api private
      def define_memoizable_names!
        names.each do |name|
          define_method(name) do
            __memoized__[__method__] ||= super()
          end
        end
      end
    end
  end
end
