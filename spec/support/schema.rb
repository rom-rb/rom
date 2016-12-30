require 'dry-types'

module SchemaHelpers
  def define_schema(name, attrs)
    ROM::Schema.define(
      name,
      attributes: attrs.map { |name, type| define_type(name, type) }
    )
  end

  def define_type(name, id, **opts)
    ROM::Types.const_get(id).meta(name: name, **opts)
  end
end
