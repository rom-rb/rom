module ROM
  # @api private
  class Mapper
    attr_reader :transformer, :header, :model

    def self.processors
      @_processors ||= {}
    end

    def self.register_processor(processor)
      name = processor.name.split('::').last.downcase.to_sym
      processors.update(name => processor)
    end

    def self.build(header, processor = :transproc)
      new(processors.fetch(processor).build(header), header)
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
