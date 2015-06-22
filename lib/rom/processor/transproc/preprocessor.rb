module ROM
  class Processor
    class Transproc < Processor
      class Preprocessor
        def initialize(header)
          @header = header
        end

        def to_transproc
          AttributesProcessor.new(@header.preprocessed).to_transproc
        end
      end
    end
  end
end