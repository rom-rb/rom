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
    DEFAULT_INFERRER = proc { [EMPTY_ARRAY, EMPTY_ARRAY].freeze }

    MissingAttributesError = Class.new(StandardError) do
      def initialize(name, attributes)
        super("missing attributes in #{name.inspect} schema: #{attributes.map(&:inspect).join(', ')}")
      end
    end

    include Dry::Equalizer(:name, :attributes, :associations)
    include Enumerable

    # @!attribute [r] name
    #   @return [Symbol] The name of this schema
    attr_reader :name

    # @!attribute [r] attributes
    #   @return [Array] Array with schema attributes
    attr_reader :attributes

    # @!attribute [r] associations
    #   @return [AssociationSet] Optional association set (this is adapter-specific)
    attr_reader :associations

    # @!attribute [r] inferrer
    #   @return [#call] An optional inferrer object used in `finalize!`
    attr_reader :inferrer

    # @api private
    attr_reader :options

    # @api private
    attr_reader :relations

    alias_method :to_ary, :attributes

    # @api public
    def self.define(name, type_class: Type, attributes: EMPTY_ARRAY, associations: EMPTY_ASSOCIATION_SET, inferrer: DEFAULT_INFERRER)
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
      attributes.map { |type| type_class.new(type) }
    end

    # @api private
    def initialize(name, options)
      @name = name
      @options = options
      @attributes = options[:attributes] || EMPTY_ARRAY
      @associations = options[:associations]
      @inferrer = options[:inferrer] || DEFAULT_INFERRER
      @relations = options[:relations] || EMPTY_HASH
    end

    # Abstract method for creating a new relation based on schema definition
    #
    # This can be used by views to generate a new relation automatically.
    # In example a schema can project a relation, join any additional relations
    # if it uncludes attributes from other relations etc.
    #
    # Default implementation is a no-op and it simply returns back untouched relation
    #
    # @param [Relation]
    #
    # @return [Relation]
    #
    # @api public
    def call(relation)
      relation
    end

    # Iterate over schema's attributes
    #
    # @yield [Schema::Type]
    #
    # @api public
    def each(&block)
      attributes.each(&block)
    end

    # @api public
    def empty?
      attributes.size == 0
    end

    # @api public
    def to_h
      each_with_object({}) { |attr, h| h[attr.name] = attr }
    end

    # Return attribute
    #
    # @api public
    def [](key, src = name.to_sym)
      attr =
        if count_index[key].equal?(1)
          name_index[key]
        else
          source_index[src][key]
        end

      unless attr
        raise(KeyError, "#{key.inspect} attribute doesn't exist in #{src} schema")
      end

      attr
    end

    # Project a schema to include only specified attributes
    #
    # @param [*Array] names Attribute names
    #
    # @return [Schema]
    #
    # @api public
    def project(*names)
      new(names.map { |name| name.is_a?(Symbol) ? self[name] : name })
    end

    # Exclude provided attributes from a schema
    #
    # @param [*Array] names Attribute names
    #
    # @return [Schema]
    #
    # @api public
    def exclude(*names)
      project(*(map(&:name) - names))
    end

    # Project a schema with renamed attributes
    #
    # @param [Hash] mapping The attribute mappings
    #
    # @return [Schema]
    #
    # @api public
    def rename(mapping)
      new_attributes = map do |attr|
        alias_name = mapping[attr.name]
        alias_name ? attr.aliased(alias_name) : attr
      end

      new(new_attributes)
    end

    # Project a schema with renamed attributes using provided prefix
    #
    # @param [Symbol] prefix The name of the prefix
    #
    # @return [Schema]
    #
    # @api public
    def prefix(prefix)
      new(map { |attr| attr.prefixed(prefix) })
    end

    # @api public
    def wrap(prefix = name.dataset)
      new(map { |attr| attr.wrapped(prefix) })
    end

    # Return FK attribute for a given relation name
    #
    # @return [Dry::Types::Definition]
    #
    # @api public
    def foreign_key(relation)
      detect { |attr| attr.foreign_key? && attr.target == relation }
    end

    # Return primary key attributes
    #
    # @return [Array<Schema::Type>]
    #
    # @api public
    def primary_key
      select(&:primary_key?)
    end

    # Merge with another schema
    #
    # @param [Schema] other Other schema
    #
    # @return [Schema]
    #
    # @api public
    def merge(other)
      new(attributes + other.attributes)
    end
    alias_method :+, :merge

    # Return if a schema includes an attribute with the given name
    #
    # @param [Symbol] name The name of the attribute
    #
    # @return [Boolean]
    #
    # @api public
    def key?(name)
      ! attributes.detect { |attr| attr.name == name }.nil?
    end

    # This hook is called when relation is being build during container finalization
    #
    # When block is provided it'll be called just before freezing the instance
    # so that additional ivars can be set
    #
    # @return [self]
    #
    # @api private
    def finalize!(gateway: nil, relations: nil, &block)
      return self if frozen?

      inferred, missing = inferrer.call(name, gateway)

      attr_names = map(&:name)
      inferred_attrs = self.class.attributes(inferred, type_class).
                         reject { |attr| attr_names.include?(attr.name) }

      attributes.concat(inferred_attrs)

      missing_attributes = missing - map(&:name)

      if missing_attributes.size > 0
        raise MissingAttributesError.new(name, missing_attributes)
      end

      options[:relations] = @relations = relations

      block.call if block

      count_index
      name_index
      source_index

      freeze
    end

    private

    # @api private
    def count_index
      @count_index ||= map(&:name).map { |name| [name, count { |attr| attr.name == name }] }.to_h
    end

    # @api private
    def name_index
      @name_index ||= map { |attr| [attr.name, attr] }.to_h
    end

    # @api private
    def source_index
      @source_index ||= select(&:source).
                          group_by(&:source).
                          map { |src, grp| [src.to_sym, grp.map { |attr| [attr.name, attr] }.to_h] }.
                          to_h
    end

    # @api private
    def type_class
      options.fetch(:type_class)
    end

    # @api private
    def new(attributes)
      self.class.new(name, options.merge(attributes: attributes))
    end
  end
end
