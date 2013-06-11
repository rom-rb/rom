require 'concord'
require 'adamantium'
require 'equalizer'
require 'abstract_type'

module ROM

  class Mapper
    include Concord.new(:header, :model)

    def self.new(header, model = OpenStruct)
      super
    end

    def load(tuple)
      model.new(
        Hash[header.map { |attribute| [ attribute.name, tuple[attribute.name] ] }]
      )
    end

    def dump(object)
      header.each_with_object([]) { |attribute, tuple|
        tuple << object.send(attribute.name)
      }
    end

  end # Mapper

end # ROM
