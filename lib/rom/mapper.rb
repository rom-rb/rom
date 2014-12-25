module ROM
  # @api private
  class Mapper
    attr_reader :transformer, :header, :model

    def self.build(header, model)
      transformer = header.to_transproc

      loader =
        if model
          -> relation { transformer[relation].map { |tuple| model.new(tuple) } }
        else
          -> relation { transformer[relation] }
        end

      new(loader, header, model)
    end

    def initialize(transformer, header, model = nil)
      @transformer = transformer
      @header = header
      @model = model
    end

    def process(relation, &block)
      transformer[relation.to_a].each(&block)
    end
  end
end
