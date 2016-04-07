require 'anima'

require 'rom/struct'

module ROM
  class Repository
    # @api private
    class StructBuilder
      attr_reader :registry

      def self.registry
        @__registry__ ||= {}
      end

      def initialize
        @registry = self.class.registry
      end

      def call(*args)
        name, header = args

        registry[args.hash] ||= build_class(name) { |klass|
          klass.send(:include, Anima.new(*visit(header)))
        }
      end
      alias_method :[], :call

      private

      def visit(ast)
        name, node = ast
        __send__("visit_#{name}", node)
      end

      def visit_header(node)
        node.map(&method(:visit))
      end

      def visit_relation(node)
        name, * = node
        name
      end

      def visit_attribute(node)
        node
      end

      def build_class(name, &block)
        ROM::ClassBuilder.new(name: class_name(name), parent: Struct).call(&block)
      end

      def class_name(name)
        "ROM::Struct[#{Inflector.classify(Inflector.singularize(name))}]"
      end
    end
  end
end
