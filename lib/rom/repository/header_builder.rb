require 'rom/header'

require 'rom/repository/struct_builder'

module ROM
  class Repository < Gateway
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

      def visit(ast, *args)
        __send__("visit_#{ast.first}", *(ast[1..ast.size-1] + args))
      end

      def visit_relation(*args)
        name, header, meta = args

        model = meta.fetch(:model) do
          struct_builder[meta.fetch(:base_name), header[1].map { |a| a[1] }]
        end

        options = [visit_header(header[1], meta), model: model]

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

      def visit_header(header, meta = {})
        header.map { |attribute| visit(attribute, meta) }
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
