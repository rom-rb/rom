module ROM
  # @api private
  class Mapper
    attr_reader :transformer, :header, :model

    def self.processors
      { transproc: Processor::Transproc }
    end

    def self.build(header, processor = :transproc)
      new(processors[processor].build(header), header)
    end

    def initialize(transformer, header)
      @transformer = transformer
      @header = header
    end

    def model
      header.model
    end

    def process(relation, &block)
      transformer[relation.to_a].each(&block)
    end
  end
end
