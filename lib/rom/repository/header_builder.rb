require 'rom/header'

require 'rom/repository/struct_builder'

module ROM
  class Repository < Gateway
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
        name, header, meta = args

        options = [
          visit(header),
          model: struct_builder[name, header[1].map { |a| a[1] }]
        ]

        if meta[:combine_type]
          type = meta[:combine_type] == :many ? :array : :hash
          keys = meta.fetch(:keys)

          [name, combine: true, type: type, keys: keys, header: Header.coerce(*options)]
        else
          options
        end
      end

      def visit_header(header)
        header.map { |attribute| visit(attribute) }
      end

      def visit_attribute(name)
        [name]
      end
    end
  end
end
