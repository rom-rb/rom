module ROM

  class Mapper
    attr_reader :header, :model

    def initialize(header, model)
      @header = header
      @model = model
    end

    def load(tuple)
      loaded_tuple = header.each_with_object({}) { |attribute, h|
        h[attribute.name] = tuple[attribute.key]
      }

      model.new(loaded_tuple)
    end

  end

end
