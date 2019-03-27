# frozen_string_literal: true

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
    include Dry::Equalizer(:attributes, :model)

    # @return [Class] optional model associated with a header
    #
    # @api private
    attr_reader :model

    # @api private
    attr_reader :reject_keys

    # @api private
    attr_reader :copy_keys

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

    # @return [Array] all attribute names that are popping from a tuple
    #
    # @api private
    attr_reader :pop_keys

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
      @options = options
      @model = options[:model]
      @copy_keys = options.fetch(:copy_keys, false)
      @reject_keys = options.fetch(:reject_keys, false)

      @attributes = attributes
      initialize_mapping
      initialize_tuple_keys
      initialize_pop_keys
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

    # Return all non-primitive attributes that don't require mapping
    #
    # @return [Array<Group,Fold,Ungroup,Unfold,Wrap,Unwrap>]
    #
    # @api private
    def non_primitives
      preprocessed + wraps
    end

    # Return all primitive attributes that require mapping
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
      @tuple_keys = mapping.keys.flatten + non_primitives.flat_map(&:tuple_keys)
    end

    # Set all tuple keys from all attributes popping from Unwrap and Ungroup
    #
    # @api private
    def initialize_pop_keys
      @pop_keys = mapping.values + non_primitives.flat_map(&:tuple_keys)
    end
  end
end
