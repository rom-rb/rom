require 'dry/types'
require 'rom/support/inflector'

module SchemaHelpers
  def define_schema(source, attrs)
    ROM::Schema.define(
      source,
      attributes: attrs.map { |name, type| define_type(name, type, source: source) }
    )
  end

  def define_type(name, id, **opts)
    ROM::Types.const_get(id).meta({name: name, **opts})
  end

  def define_attribute(*args)
    ROM::Attribute.new(define_type(*args))
  end

  def build_assoc(type, *args)
    klass = ROM::Inflector.classify(type)
    definition = ROM::Associations::Definitions.const_get(klass).new(*args)
    ROM::Memory::Associations.const_get(definition.type).new(definition, relations)
  end
end
