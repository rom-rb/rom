require 'rom/header/attribute'

module ROM
  # @api private
  class Header
    include Enumerable
    include Equalizer.new(:attributes, :model)

    attr_reader :attributes, :model, :mapping, :tuple_keys

    def self.coerce(input, model = nil)
      if input.instance_of?(self)
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
      initialize_mapping
      initialize_tuple_keys
    end

    def each(&block)
      attributes.values.each(&block)
    end

    def aliased?
      any?(&:aliased?)
    end

    def keys
      attributes.keys
    end

    def [](name)
      attributes.fetch(name)
    end

    def groups
      by_type(Group)
    end

    def wraps
      by_type(Wrap)
    end

    private

    def by_type(*types)
      select { |attribute| types.include?(attribute.class) }
    end

    def initialize_mapping
      @mapping = by_type(Attribute, Array, Hash).map(&:mapping).reduce(:merge) || {}
    end

    def initialize_tuple_keys
      mapping_keys = mapping.keys
      groups_tuple_keys = groups.map(&:tuple_keys)
      wraps_tuple_keys = wraps.map(&:tuple_keys)

      @tuple_keys = (mapping_keys + wraps_tuple_keys + groups_tuple_keys).flatten
    end
  end
end
