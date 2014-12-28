require 'rom/mapper'

module ROM
  class Processor
    def self.inherited(processor)
      Mapper.register_processor(processor)
    end

    def self.build
      raise NotImplementedError, "+build+ must be implemented"
    end
  end
end
