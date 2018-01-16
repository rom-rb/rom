require 'rom/support/inflector'
require 'dry/core/class_builder'
require 'dry/types/compiler'

require 'rom/initializer'
require 'rom/types'
require 'rom/cache'
require 'rom/struct'
require 'rom/open_struct'
require 'rom/attribute'

module ROM
  # @api private
  class StructCompiler < Dry::Types::Compiler
    extend Initializer

    param :registry, default: -> { Dry::Types }
    option :cache, default: -> { Cache.new }

    # @api private
    def initialize(*args)
      super
      @cache = cache.namespaced(:structs)
    end

    # Build a struct class based on relation header ast
    #
    # @api private
    def call(*args)
      cache.fetch_or_store(args) do
        name, header, ns = args
        attributes = header.map(&method(:visit)).compact

        if attributes.empty?
          ROM::OpenStruct
        else
          build_class(name, ROM::Struct, ns) do |klass|
            attributes.each do |attr_name, type|
              klass.attribute(attr_name, type)
            end
          end
        end
      end
    end
    alias_method :[], :call

    private

    # @api private
    def visit_relation(node)
      _, header, meta = node
      name = meta[:combine_name] || meta[:alias]
      namespace = meta.fetch(:struct_namespace)

      model = meta[:model] || call(name, header, namespace)

      member =
        if model < Dry::Struct
          model
        else
          Dry::Types::Definition.new(model).constructor(&model.method(:new))
        end

      if meta[:combine_type] == :many
        [name, Types::Array.of(member)]
      else
        [name, member.optional]
      end
    end

    # @api private
    def visit_attribute(node)
      name, type, meta = node

      [meta[:alias] && !meta[:wrapped] ? meta[:alias] : name, visit(type).meta(meta)]
    end

    # @api private
    def visit_constructor(node)
      definition, * = node

      visit(definition)
    end

    # @api private
    def visit_constrained(node)
      definition, _ = node

      visit(definition)
    end

    # @api private
    def visit_enum(node)
      type_node, * = node
      visit(type_node)
    end

    # @api private
    def build_class(name, parent, ns, &block)
      Dry::Core::ClassBuilder.
        new(name: class_name(name), parent: parent, namespace: ns).
        call(&block)
    end

    # @api private
    def class_name(name)
      Inflector.classify(Inflector.singularize(name))
    end
  end
end
