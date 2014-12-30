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

    def primitives
      to_a - non_primitives
    end

    def non_primitives
      groups + wraps
    end

    private

    def by_type(*types)
      select { |attribute| types.include?(attribute.class) }
    end

    def initialize_mapping
      @mapping = primitives.map(&:mapping).reduce(:merge) || {}
    end

    def initialize_tuple_keys
      @tuple_keys = mapping.keys + non_primitives.map(&:tuple_keys).flatten
    end
  end
end
