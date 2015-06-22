require 'rom/processor/transproc/combined_attribute'

module ROM
  class Processor
    class Transproc < Processor
      class CombineProcessor
        include ::Transproc::Helper

        def initialize(header)
          @header = header
        end

        def to_transproc
          t(:combine, combined.map { |attribute| CombinedAttribute.new(attribute).to_transproc_args }) if combined.any?
        end

        private

        def combined
          @header.combined
        end
      end
    end
  end
end
