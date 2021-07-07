# frozen_string_literal: true

require "dry/inflector"

module ROM
  module InflectorMethods
    # ZeitwerkCompatibility
    def camelize(name, *)
      super(name)
    end

    # Default for inferring ids from class names
    def component_id(value)
      name = (value.is_a?(Class) ? (value.name || value.superclass.name) : value).to_s
      underscore(demodulize(name))
    end
  end

  Inflector = Dry::Inflector.new do |i|
    i.plural(/people\z/i, "people")
  end

  Inflector.extend(InflectorMethods)
end
