module ROM
  class Processor
    class Transproc < Processor
      class Postprocessor
        def initialize(header)
          @header = header
        end

        def to_transproc
          AttributesProcessor.new(@header.postprocessed).to_transproc
        end
      end
    end
  end
end