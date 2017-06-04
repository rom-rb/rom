require 'rom/header'
require 'rom/struct_builder'

module ROM
  # @api private
  class HeaderBuilder
    attr_reader :struct_builder

    def initialize(struct_namespace: nil, **options)
      @struct_builder = StructBuilder.new(struct_namespace)
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
      relation_name, header, meta = node
      name = meta[:combine_name] || relation_name

      model = meta.fetch(:model) do
        if meta[:combine_name]
          false
        else
          struct_builder[name, header]
        end
      end

      options = [header.map(&method(:visit)), model: model]

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

    def visit_attribute(attr)
      if attr.wrapped?
        [attr.name, from: attr.alias]
      else
        [attr.name]
      end
    end
  end
end
