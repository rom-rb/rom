module ROM

  class Mapper
    attr_reader :header, :model

    def initialize(header, model)
      @header = header
      @model = model
    end

    def load(tuple)
      model.new(tuple)
    end

  end

end
