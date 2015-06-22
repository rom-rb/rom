require 'rom/processor/transproc/attribute'

module ROM
  class Processor
    class Transproc < Processor
      class AttributesProcessor

        def initialize(attributes)
          @attributes = attributes
        end

        def to_transproc
          @attributes.map { |attr| Attribute.new(attr, true).to_transproc }
        end

      end
    end
  end
end