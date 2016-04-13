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
      def aggregate(options)
        root.combine_children(options)
      end
    end
  end
end
