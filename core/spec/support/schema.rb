require 'dry/types'
require 'rom/support/inflector'

module SchemaHelpers
  def define_schema(source, attrs)
    ROM::Schema.define(
      source,
      attributes: attrs.map do |name, id|
        {
          type: define_type(id, source: source),
          options: { name: name }
        }
      end)
  end

  def define_type(id, **meta)
    ROM::Types.const_get(id).meta(**meta)
  end

  # @todo Use this method consistently in all the test suite
  def define_attribute(id, opts, **meta)
    type = define_type(id, **meta)
    ROM::Attribute.new(type, opts)
  end

  def define_attr_info(id, opts, **meta)
    ROM::Schema.build_attribute_info(
      define_type(id, **meta),
      opts
    )
  end

  def build_assoc(type, *args)
    klass = ROM::Inflector.classify(type)
    definition = ROM::Associations::Definitions.const_get(klass).new(*args)
    ROM::Memory::Associations.const_get(definition.type).new(definition, relations)
  end
end
