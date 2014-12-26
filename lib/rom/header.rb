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
      initialize_tuple_proc
    end

    def t(*args)
      Transproc(*args)
    end

    def to_transproc
      ops = []
      ops += map(&:preprocessor).compact
      ops << t(:map_array!, tuple_proc) if tuple_proc

      ops.reduce(:+) || t(-> tuple { tuple })
    end

    def each(&block)
      return to_enum unless block
      attributes.values.each(&block)
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

    private

    def initialize_tuple_proc
      @mapping = attributes.values.reject(&:preprocessor).map(&:mapping).reduce(:merge)

      ops = []
      ops << t(:map_hash!, mapping) if any?(&:aliased?)
      ops += map(&:to_transproc).compact
      ops << t(-> tuple { model.new(tuple) }) if model

      @tuple_proc = ops.reduce(:+)
    end
  end
end
