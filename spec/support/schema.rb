require 'dry-types'

module SchemaHelpers
  def define_schema(source, attrs)
    ROM::Schema.define(
      source,
      attributes: attrs.map { |name, type| define_type(name, type, source: source) }
    )
  end

  def define_type(name, id, **opts)
    ROM::Types.const_get(id).meta(name: name, **opts)
  end
end
