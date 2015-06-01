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

    # Return all Combined attributes
    #
    # @return [Array<Combined>]
    #
    # @api private
    def combined
      by_type(Combined)
    end

    # Returns all attributes that require preprocessing
    #
    # @return [Array<Group,Fold>]
    #
    # @api private
    def preprocessed
      by_type(Group, Fold)
    end

    # Returns all attributes that require postprocessing
    #
    # @return [Array<Ungroup,Unfold>]
    #
    # @api private
    def postprocessed
      by_type(Ungroup, Unfold)
    end

    # Return all Wrap attributes
    #
    # @return [Array<Wrap>]
    #
    # @api private
    def wraps
      by_type(Wrap)
    end

    # Return all non-primitive attributes
    #
    # @return [Array<Group,Fold,Ungroup,Unfold,Wrap>]
    #
    # @api private
    def non_primitives
      preprocessed + postprocessed + wraps
    end

    # Return all primitive attributes that doesn't nest other ones
    #
    # @return [Array<Attribute>]
    #
    # @api private
    def primitives
      to_a - non_primitives
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
