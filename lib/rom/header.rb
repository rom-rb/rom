require 'rom/header/attribute'

module ROM
  # @api private
  class Header
    include Enumerable
    include Equalizer.new(:attributes)

    attr_reader :attributes, :mapping, :by_key

    def self.coerce(input)
      if input.is_a?(self)
        input
      else
        attributes = input.each_with_object({}) { |pair, h|
          h[pair.first] = Attribute.coerce(pair)
        }

        new(attributes)
      end
    end

    def initialize(attributes)
      @attributes = attributes
      @by_key = attributes.
        values.each_with_object({}) { |attr, h| h[attr.key] = attr }
      @mapping = Hash[
        reject(&:embedded?).map(&:mapping) +
        select(&:embedded?).map { |attr| [attr.key, attr.name] }
      ]
    end

    def to_transproc
      embedded_ops = select(&:embedded?).map(&:to_transproc).reduce(:+)
      base_ops = Transproc(:map_array, Transproc(:map_hash, mapping))

      if embedded_ops
        embedded_ops + base_ops
      else
        base_ops
      end
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
  end
end
