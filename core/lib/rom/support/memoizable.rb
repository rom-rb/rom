module ROM
  # @api private
  module Memoizable
    MEMOIZED_HASH = {}

    module ClassInterface
      # @api private
      def memoize(*names)
        prepend(Memoizer.new(names))
      end

      def new(*)
        obj = super
        obj.instance_variable_set(:'@__memoized__', MEMOIZED_HASH.dup)
        obj
      end
    end

    def self.included(klass)
      super
      klass.extend(ClassInterface)
    end

    attr_reader :__memoized__

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
