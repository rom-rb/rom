module ROM
  class Repository
    class Root < Repository
      extend ClassMacros

      defines :root

      attr_reader :root

      # @api private
      def self.inherited(klass)
        super
        klass.root(root)
      end

      # @api private
      def initialize(container)
        super
        @root = __send__(self.class.root)
      end

      # @api public
      def aggregate(*args)
        if args[0].is_a?(Hash) && args.size == 1
          root.combine_children(args[0])
        else
          root.combine(*args)
        end
      end
    end
  end
end
