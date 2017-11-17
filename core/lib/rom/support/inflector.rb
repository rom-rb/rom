require 'dry/inflector'

module ROM
  DOUBLE_COLON = '::'.freeze

  Inflector = Dry::Inflector.new do |i|
    i.plural(/people\z/i, 'people')
  end
end
