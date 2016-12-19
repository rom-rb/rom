require 'dry-types'

module SchemaHelpers
  def define_schema(name, attrs)
    ROM::Schema.define(
      name,
      attributes: attrs.each_with_object({}) { |(k, v), h| h[k] = v.meta(name: k) }
    )
  end
end
