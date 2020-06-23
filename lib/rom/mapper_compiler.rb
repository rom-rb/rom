# frozen_string_literal: true

require "dry/core/class_attributes"

require "rom/constants"
require "rom/initializer"
require "rom/mapper"
require "rom/struct"
require "rom/struct_compiler"
require "rom/cache"

module ROM
  # @api private
  class MapperCompiler
    extend Dry::Core::ClassAttributes
    extend Initializer

    defines :mapper_options

    mapper_options(EMPTY_HASH)

    option :cache, default: -> { Cache.new }

    attr_reader :struct_compiler

    attr_reader :mapper_options

    def initialize(*)
      super
      @struct_compiler = StructCompiler.new(cache: cache)
      @cache = cache.namespaced(:mappers)
      @mapper_options = self.class.mapper_options
    end
    ruby2_keywords(:initialize) if respond_to?(:ruby2_keywords, true)

    def call(ast)
      cache.fetch_or_store(ast.hash) { Mapper.build(Header.coerce(*visit(ast))) }
    end
    alias_method :[], :call

    private

    def visit(node)
      name, node = node
      __send__("visit_#{name}", node)
    end

    def visit_relation(node)
      rel_name, header, meta_options = node
      name = meta_options[:combine_name] || meta_options[:alias] || rel_name
      namespace = meta_options.fetch(:struct_namespace)

      model = meta_options.fetch(:model) do
        if meta_options[:combine_name]
          false
        else
          struct_compiler[name, header, namespace]
        end
      end

      options = [header.map(&method(:visit)), mapper_options.merge(model: model)]

      if meta_options[:combine_type]
        type = meta_options[:combine_type] == :many ? :array : :hash
        keys = meta_options.fetch(:keys)

        [name, combine: true, type: type, keys: keys, header: Header.coerce(*options)]
      elsif meta_options[:wrap]
        [name, wrap: true, type: :hash, header: Header.coerce(*options)]
      else
        options
      end
    end

    def visit_attribute(node)
      name, _, meta_options = node

      if meta_options[:alias]
        [meta_options[:alias], from: name]
      else
        [name]
      end
    end
  end
end
