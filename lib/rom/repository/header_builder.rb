require 'rom/header'

require 'rom/repository/struct_builder'

module ROM
  class Repository
    # @api private
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

      def visit(node, *args)
        name, node = node
        __send__("visit_#{name}", node, *args)
      end

      def visit_relation(node, meta = {})
        name, meta, header = node

        model = meta.fetch(:model) do
          struct_builder[meta.fetch(:base_name), header]
        end

        options = [visit(header, meta), model: model]

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

      def visit_header(node, meta = {})
        node.map { |attribute| visit(attribute, meta) }
      end

      def visit_attribute(name, meta = {})
        if meta[:wrap]
          [name, from: :"#{meta[:base_name]}_#{name}"]
        else
          [name]
        end
      end
    end
  end
end
