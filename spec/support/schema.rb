require 'dry-types'

module SchemaHelpers
  def define_schema(name, attrs)
    ROM::Schema.define(
      name,
      attributes: attrs.map { |key, value| value.meta(name: key) }
    )
  end
end
