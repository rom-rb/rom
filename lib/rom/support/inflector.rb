# frozen_string_literal: true

require "dry/inflector"

module ROM
  module ZeitwerkCompatibility
    def camelize(name, *)
      super(name)
    end
  end

  Inflector = Dry::Inflector.new do |i|
    i.plural(/people\z/i, "people")
  end

  Inflector.extend(ZeitwerkCompatibility)
end
