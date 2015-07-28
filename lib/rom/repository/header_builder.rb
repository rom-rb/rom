require 'rom/header'

require 'rom/repository/struct_builder'

module ROM
  class Repository
    class HeaderBuilder
      attr_reader :struct_builder

      def self.new(struct_builder = StructBuilder.new)
        super
      end

      def initialize(struct_builder)
        @struct_builder = struct_builder
      end

      def call(ast)
        Header.coerce(*visit(ast))
      end
      alias_method :[], :call

      private

      def visit(ast)
        __send__("visit_#{ast.first}", *ast[1..ast.size-1])
      end

      def visit_relation(*args)
        name, columns = args

        [columns.map { |col| [col] }, model: struct_builder[name, columns]]
      end

      def visit_graph(*args)
        root, nodes = args
        root_attrs, _options = visit(root)

        children = nodes.map do |node|
          type = node.last[:combine_type] == :many ? :array : :hash

          [
            node[1],
            combine: true,
            type: type,
            keys: { id: combine_key(root) },
            header: call(node)
          ]
        end

        attributes = root_attrs + children

        [attributes, model: struct_builder[root[1], attributes.map(&:first)]]
      end

      # TODO: this should be an injectible strategy so we can easily configure it
      def combine_key(node)
        :"#{Inflector.singularize(node[1])}_id"
      end
    end
  end
end
