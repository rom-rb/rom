require 'concurrent/map'

require 'rom/struct'
require 'rom/support/constants'
require 'rom/repository/struct_attributes'

module ROM
  class Repository
    # @api private
    class StructBuilder
      attr_reader :registry

      # @api private
      def self.registry
        @registry ||= Concurrent::Map.new
      end

      def initialize
        @registry = self.class.registry
      end

      def call(*args)
        name, header = args

        registry[args.hash] ||= build_class(name) { |klass|
          klass.send(:include, StructAttributes.new(visit(header)))
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
        relation_name, meta, * = node
        meta[:combine_name] || relation_name.relation
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
