require 'dry-equalizer'

require 'rom/schema/type'
require 'rom/schema/dsl'
require 'rom/association_set'

module ROM
  # Relation schema
  #
  # @api public
  class Schema
    EMPTY_ASSOCIATION_SET = AssociationSet.new(EMPTY_HASH).freeze

    include Dry::Equalizer(:name, :attributes, :associations)
    include Enumerable

    # @!attribute [r] name
    #   @return [Symbol] The name of this schema
    attr_reader :name

    # @!attribute [r] attributes
    #   @return [Hash] The hash with schema attribute types
    attr_reader :attributes

    # @!attribute [r] associations
    #   @return [AssociationSet] Optional association set (this is adapter-specific)
    attr_reader :associations

    # @!attribute [r] inferrer
    #   @return [#call] An optional inferrer object used in `finalize!`
    attr_reader :inferrer

    # @!attribute [r] primary_key
    #   @return [Array<Dry::Types::Definition] Primary key array
    attr_reader :primary_key

    # @api private
    attr_reader :options

    alias_method :to_h, :attributes

    # @api public
    def self.define(name, type_class: Type, attributes: EMPTY_HASH, associations: EMPTY_ASSOCIATION_SET, inferrer: nil)
      new(
        name,
        attributes: attributes(attributes, type_class),
        associations: associations,
        inferrer: inferrer,
        type_class: type_class
      )
    end

    # @api private
    def self.attributes(attributes, type_class)
      attributes.each_with_object({}) { |(a, e), h| h[a] = type_class.new(e) }
    end

    # @api private
    def initialize(name, options)
      @name = name
      @options = options
      @attributes = options[:attributes]
      @associations = options[:associations]
      @inferrer = options[:inferrer]
    end

    # Iterate over schema's attributes
    #
    # @yield [Dry::Data::Type]
    #
    # @api public
    def each(&block)
      attributes.each_value(&block)
    end

    # @api public
    def empty?
      attributes.size == 0
    end

    # @api public
    def to_ary
      map { |attribute| attribute.meta[:name] }
    end

    # Return attribute
    #
    # @api public
    def [](name)
      attributes.fetch(name)
    end

    # Project a schema to include only specified attributes
    #
    # @param [*Array] names The name of the attributes
    #
    # @return [Schema]
    #
    # @api public
    def project(*names)
      self.class.new(name, options.merge(attributes: attributes.select { |key, _| names.include?(key) }))
    end

    # Return FK attribute for a given relation name
    #
    # @return [Dry::Types::Definition]
    #
    # @api public
    def foreign_key(relation)
      detect { |attr| attr.foreign_key? && attr.relation == relation }
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
      return self if frozen?

      @attributes = self.class.attributes(inferrer.call(name.dataset, gateway), type_class) if inferrer
      @primary_key = select(&:primary_key?)
      block.call if block
      freeze
    end

    private

    def type_class
      options.fetch(:type_class)
    end
  end
end
