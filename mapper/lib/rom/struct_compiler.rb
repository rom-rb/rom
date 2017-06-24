require 'dry/core/inflector'
require 'dry/core/class_builder'
require 'dry/types/compiler'

require 'rom/initializer'
require 'rom/types'
require 'rom/cache'
require 'rom/struct'
require 'rom/open_struct'
require 'rom/schema/attribute'

module ROM
  # @api private
  class StructCompiler < Dry::Types::Compiler
    extend Initializer

    param :registry, default: -> { Dry::Types }
    option :namespace, reader: true, default: -> { ROM::Struct }
    option :cache, reader: true, default: -> { Cache.new }

    def initialize(*args)
      super
      @cache = cache.namespaced(:structs)
    end

    def call(*args)
      cache.fetch_or_store(*args) do
        name, header = args
        attributes = header.map(&method(:visit)).compact

        if attributes.empty?
          ROM::OpenStruct
        else
          build_class(name, ROM::Struct) do |klass|
            attributes.each do |(name, type)|
              klass.attribute(name, type)
            end
          end
        end
      end
    end
    alias_method :[], :call

    private

    def visit_relation(node)
      relation_name, header, meta = node
      name = meta[:combine_name] || relation_name.relation

      model = meta[:model] || call(name, header)

      member =
        if model < Dry::Struct
          model
        else
          Dry::Types::Definition.new(model).constructor(&model.method(:new))
        end

      if meta[:combine_type] == :many
        [name, Types::Array.member(member)]
      else
        [name, member.optional]
      end
    end

    def visit_attribute(node)
      name, type, meta = node

      [meta[:alias] && !meta[:wrapped] ? meta[:alias] : name, visit(type).meta(meta)]
    end

    def visit_constructor(node)
      definition, fn_register_name, meta = node

      visit(definition)
    end

    def visit_constrained(node)
      definition, rule = node

      visit(definition)
    end

    def build_class(name, parent, &block)
      Dry::Core::ClassBuilder.new(name: class_name(name), parent: parent, namespace: namespace).call(&block)
    end

    def class_name(name)
      Dry::Core::Inflector.classify(Dry::Core::Inflector.singularize(name))
    end
  end
end
