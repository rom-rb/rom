# frozen_string_literal: true

module ROM
  Inflector = Dry::Inflector.new do |i|
    i.plural(/people\z/i, 'people')
  end
end
