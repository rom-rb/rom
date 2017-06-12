require 'rom/initializer'
require 'rom/mapper'
require 'rom/struct'
require 'rom/struct_builder'
require 'rom/cache'

module ROM
  # @api private
  class MapperCompiler
    extend Initializer

    option :cache, reader: true, default: -> { Cache.new }
    option :struct_namespace, reader: true, default: -> { ROM::Struct }

    attr_reader :struct_builder

    def initialize(*args)
      super
      @struct_builder = StructBuilder.new(namespace: struct_namespace, cache: cache)
      @cache = cache.namespaced(:mappers)
    end

    def call(ast)
      cache.fetch_or_store(ast) { Mapper.build(Header.coerce(*visit(ast))) }
    end
    alias_method :[], :call

    def with(new_options)
      self.class.new(options.merge(new_options))
    end

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

    def visit_attribute(node)
      name, _, meta = node

      if meta[:wrapped]
        [name, from: meta[:alias]]
      else
        [name]
      end
    end
  end
end
