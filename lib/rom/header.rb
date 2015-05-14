require 'equalizer'

require 'rom/support/options'
require 'rom/header/attribute'

module ROM
  # Header provides information about data mapping of a specific relation
  #
  # Processors use headers to build objects that process raw relations that go
  # through mappers.
  #
  # @private
  class Header
    include Enumerable
    include Options
    include Equalizer.new(:attributes, :model)

    # @return [Class] optional model associated with a header
    #
    # @api private
    option :model, reader: true

    option :reject_keys, reader: true, default: false

    # @api private
    attr_reader :attributes

    # @return [Hash] attribute key/name mapping for all primitive attributes
    #
    # @api private
    attr_reader :mapping

    # @return [Array] all attribute keys that are in a tuple
    #
    # @api private
    attr_reader :tuple_keys

    # Coerce array with attribute definitions into a header object
    #
    # @param [Array<Array>] input attribute name/option pairs
    #
    # @param [Class] model optional
    #
    # @return [Header]
    #
    # @api private
    def self.coerce(input, options = {})
      if input.instance_of?(self)
        input
      else
        attributes = input.each_with_object({}) { |pair, h|
          h[pair.first] = Attribute.coerce(pair)
        }

        new(attributes, options)
      end
    end

    # @api private
    def initialize(attributes, options = {})
      super
      @attributes = attributes
      initialize_mapping
      initialize_tuple_keys
    end

    # Iterate over attributes
    #
    # @yield [Attribute]
    #
    # @api private
    def each
      attributes.each_value { |attribute| yield(attribute) }
    end

    # Return if there are any aliased attributes
    #
    # @api private
    def aliased?
      any?(&:aliased?)
    end

    # Return attribute keys
    #
    # An attribute key corresponds to tuple attribute names
    #
    # @api private
    def keys
      attributes.keys
    end

    # Return attribute identified by its name
    #
    # @return [Attribute]
    #
    # @api private
    def [](name)
      attributes.fetch(name)
    end

    # Return all Group attributes
    #
    # @return [Array<Group>]
    #
    # @api private
    def groups
      by_type(Group)
    end

    # Return all Wrap attributes
    #
    # @return [Array<Wrap>]
    #
    # @api private
    def wraps
      by_type(Wrap)
    end

    # @api private
    def combined
      by_type(Combined)
    end

    # Return all primitive attributes (no Group and Wrap)
    #
    # @return [Array<Attribute>]
    #
    # @api private
    def primitives
      to_a - non_primitives
    end

    # Return all non-primitive attributes (only Group and Wrap types)
    #
    # @return [Array<Group,Wrap>]
    #
    # @api private
    def non_primitives
      groups + wraps
    end

    private

    # Find all attribute matching specific attribute class (not kind)
    #
    # @return [Array<Attribute>]
    #
    # @api private
    def by_type(*types)
      select { |attribute| types.include?(attribute.class) }
    end

    # Set mapping hash from primitive attributes
    #
    # @api private
    def initialize_mapping
      @mapping = primitives.map(&:mapping).reduce(:merge) || {}
    end

    # Set all tuple keys from all attributes going deep into Wrap and Group too
    #
    # @api private
    def initialize_tuple_keys
      @tuple_keys = mapping.keys + non_primitives.flat_map(&:tuple_keys)
    end
  end
end
