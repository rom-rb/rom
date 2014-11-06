module ROM

  class Mapper
    attr_reader :header, :model, :mapping

    def initialize(header, model)
      @header = header
      @model = model
      @mapping = header.mapping
    end

    def load(tuple)
      model.new(Hash[tuple.map { |k, v| [mapping[k], v] }])
    end

  end

end
