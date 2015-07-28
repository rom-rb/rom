require 'rom/header'
require 'rom/repository/ext/relation'
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

      def call(relation)
        Header.coerce(*visit(relation.to_ast))
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
          [node[1],
           combine: true,
           # TODO: find a way of configuring :hash too (aka "has_one"/"belongs_to")
           type: :array,
           keys: { id: combine_key(root) },
           header: Header.coerce(*visit(node))]
        end

        attributes = root_attrs + children

        # TODO: find a way of configuring how keys should be named
        #       right now we default to child relation name
        [attributes, model: struct_builder[root[1], attributes.map(&:first)]]
      end

      # TODO: this should be an injectible strategy so we can easily configure it
      def combine_key(node)
        :"#{Inflector.singularize(node[1])}_id"
      end
    end
  end
end
