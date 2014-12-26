require 'rom/header/attribute'
require 'rom/header/attribute/embedded'
require 'rom/header/attribute/hash'
require 'rom/header/attribute/array'
require 'rom/header/attribute/wrap'
require 'rom/header/attribute/group'

module ROM
  # @api private
  class Header
    include Enumerable
    include Equalizer.new(:attributes, :model)

    attr_reader :attributes, :model, :mapping, :tuple_proc

    def self.coerce(input, model = nil)
      if input.is_a?(self)
        input
      else
        attributes = input.each_with_object({}) { |pair, h|
          h[pair.first] = Attribute.coerce(pair)
        }

        new(attributes, model)
      end
    end

    def initialize(attributes, model = nil)
      @attributes = attributes
      @model = model
      @mapping = reject(&:preprocess?).map(&:mapping).reduce(:merge)
    end

    def each(&block)
      return to_enum unless block
      attributes.values.each(&block)
    end

    def preprocess?
      any?(&:preprocess?)
    end

    def aliased?
      any?(&:aliased?)
    end

    def keys
      attributes.keys
    end

    def values
      attributes.values
    end

    def [](name)
      attributes.fetch(name)
    end
  end
end
