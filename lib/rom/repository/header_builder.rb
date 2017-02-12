require 'rom/header'
require 'rom/repository/struct_builder'

module ROM
  class Repository
    # @api private
    class HeaderBuilder
      attr_reader :struct_builder

      def initialize
        @struct_builder = StructBuilder.new
      end

      def call(ast)
        Header.coerce(*visit(ast))
      end
      alias_method :[], :call

      private

      def visit(node)
        name, node = node
        __send__("visit_#{name}", node)
      end

      def visit_relation(node)
        relation_name, meta, header = node
        name = meta[:combine_name] || relation_name

        model = meta.fetch(:model) do
          struct_builder[meta.fetch(:dataset), header]
        end

        options = [visit(header), model: model]

        if meta[:combine_type]
          type = meta[:combine_type] == :many ? :array : :hash
          keys = meta.fetch(:keys)

          [name, combine: true, type: type, keys: keys, header: Header.coerce(*options)]
        elsif meta[:wrap]
          [name, wrap: true, type: :hash, header: Header.coerce(*options)]
        else
          options
        end
      end

      def visit_header(node)
        node.map { |attribute| visit(attribute) }
      end

      def visit_attribute(attr)
        if attr.wrapped?
          [attr.name, from: attr.alias]
        else
          [attr.name]
        end
      end
    end
  end
end
