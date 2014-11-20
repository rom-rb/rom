module ROM

  class Mapper
    attr_reader :header, :model, :mapping

    def initialize(header, model)
      @header = header
      @model = model
      @mapping = header.mapping
    end

    def load(tuple, mapping = mapping)
      model.new(Hash[call(tuple, mapping)])
    end

    def call(tuple, mapping = mapping)
      tuple.map do |key, value|
        case value
        when Hash  then [key, Hash[call(value, mapping[key])]]
        when Array then [key, value.map { |v| Hash[call(v, mapping[key])] }]
        else
          [mapping[key], value]
        end
      end
    end

  end

end
