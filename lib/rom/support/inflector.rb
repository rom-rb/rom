# frozen_string_literal: true

require "dry/inflector"

module ROM
  module InflectorMethods
    # ZeitwerkCompatibility
    def camelize(name, *)
      super(name)
    end

    # Default for inferring ids from class names or any string/symbol
    def component_id(value)
      name = (value.is_a?(Class) ? (value.name || value.superclass.name) : value).to_s
      underscore(demodulize(name)).to_sym
    end

    # Default for inferring namespace from class names or any string/symbol
    def namespace(value)
      name = (value.is_a?(Class) ? (value.name || value.superclass.name) : value).to_s
      pluralize(underscore(demodulize(name))).to_sym
    end
  end

  Inflector = Dry::Inflector.new do |i|
    i.plural(/people\z/i, "people")
    i.plural(/schema\z/i, "schemas")
  end

  Inflector.extend(InflectorMethods)
end
