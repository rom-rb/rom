require 'dry-equalizer'
require 'rom/schema/dsl'

module ROM
  # Relation schema
  #
  # @api public
  class Schema
    include Dry::Equalizer(:name, :attributes)
    include Enumerable

    # @!attribute [r] name
    #   @return [Symbol] The name of this schema
    attr_reader :name

    # @!attribute [r] attributes
    #   @return [Hash] The hash with schema attribute types
    attr_reader :attributes

    # @!attribute [r] inferrer
    #   @return [#call] An optional inferrer object used in `finalize!`
    attr_reader :inferrer

    # @!attribute [r] primary_key
    #   @return [Array<Dry::Types::Definition] Primary key array
    attr_reader :primary_key

    # @api private
    def initialize(name, attributes, inferrer: nil)
      @name = name
      @attributes = attributes
      @inferrer = inferrer
    end

    # Iterate over schema's attributes
    #
    # @yield [Dry::Data::Type]
    #
    # @api public
    def each(&block)
      attributes.each_value(&block)
    end

    # Return attribute
    #
    # @api public
    def [](name)
      attributes.fetch(name)
    end

    # Return FK attribute for a given relation name
    #
    # @return [Dry::Types::Definition]
    #
    # @api public
    def foreign_key(relation)
      detect { |attr| attr.meta[:foreign_key] && attr.meta[:relation] == relation }
    end

    # This hook is called when relation is being build during container finalization
    #
    # When block is provided it'll be called just before freezing the instance
    # so that additional ivars can be set
    #
    # @return [self]
    #
    # @api private
    def finalize!(gateway = nil, &block)
      @attributes = inferrer.call(name.dataset, gateway) if inferrer
      @primary_key = select { |attr| attr.meta[:primary_key] == true }
      block.call if block
      freeze
    end
  end
end
