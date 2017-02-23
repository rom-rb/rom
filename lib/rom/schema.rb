require 'dry-equalizer'

require 'rom/schema/attribute'
require 'rom/schema/dsl'
require 'rom/association_set'

module ROM
  # Relation schema
  #
  # Schemas hold detailed information about relation tuples, including their
  # primitive types (String, Integer, Hash, etc. or custom classes), as well as
  # various meta information like primary/foreign key and literally any other
  # information that a given database adapter may need.
  #
  # Adapters can extend this class and it can be used in adapter-specific relations.
  # In example rom-sql extends schema with Association DSL and many additional
  # SQL-specific APIs in schema types.
  #
  # Schemas are used for projecting canonical relations into other relations and
  # every relation object maintains its schema. This means that we always have
  # all information about relation tuples, even when a relation was projected and
  # diverged from its canonical form.
  #
  # Furthermore schema attributes know their source relations, which makes it
  # possible to merge schemas from multiple relations and maintain information
  # about the source relations. In example when two relations are joined, their
  # schemas are merged, and we know which attributes belong to which relation.
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

    # Define a relation schema from plain rom types
    #
    # Resulting schema will decorate plain rom types with adapter-specific types
    # By default `Schema::Attribute` will be used
    #
    # @param [Relation::Name, Symbol] name The schema name, typically ROM::Relation::Name
    #
    # @return [Schema]
    #
    # @api public
    def self.define(name, attr_class: Attribute, attributes: EMPTY_ARRAY, associations: EMPTY_ASSOCIATION_SET, inferrer: DEFAULT_INFERRER)
      new(
        name,
        attributes: attributes(attributes, attr_class),
        associations: associations,
        inferrer: inferrer,
        attr_class: attr_class
      )
    end

    # @api private
    def self.attributes(attributes, attr_class)
      attributes.map { |type| attr_class.new(type) }
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
    # @yield [Schema::Attribute]
    #
    # @api public
    def each(&block)
      attributes.each(&block)
    end

    # Check if schema has any attributes
    #
    # @return [TrueClass, FalseClass]
    #
    # @api public
    def empty?
      attributes.size == 0
    end

    # Coerce schema into a <AttributeName=>Attribute> Hash
    #
    # @return [Hash]
    #
    # @api public
    def to_h
      each_with_object({}) { |attr, h| h[attr.name] = attr }
    end

    # Return attribute
    #
    # @param [Symbol] key The attribute name
    # @param [Symbol, Relation::Name] src The source relation (for merged schemas)
    #
    # @raise KeyError
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
    # @param [*Array<Symbol, Schema::Attribute>] names Attribute names
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

    # Return new schema with all attributes marked as prefixed and wrapped
    #
    # This is useful when relations are joined and the right side should be marked
    # as wrapped
    #
    # @param [Symbol] prefix The prefix used for aliasing wrapped attributes
    #
    # @return [Schema]
    #
    # @api public
    def wrap(prefix = name.dataset)
      new(map { |attr| attr.wrapped? ? attr : attr.wrapped(prefix) })
    end

    # Return FK attribute for a given relation name
    #
    # @return [Schema::Attribute]
    #
    # @api public
    def foreign_key(relation)
      detect { |attr| attr.foreign_key? && attr.target == relation }
    end

    # Return primary key attributes
    #
    # @return [Array<Schema::Attribute>]
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
      append(*other)
    end
    alias_method :+, :merge

    # Append more attributes to the schema
    #
    # This returns a new schema instance
    #
    # @param [*Array<Schema::Attribute>]
    #
    # @return [Schema]
    #
    # @api public
    def append(*new_attributes)
      new(attributes + new_attributes)
    end

    # Return a new schema with uniq attributes
    #
    # @param [*Array<Schema::Attribute>]
    #
    # @return [Schema]
    #
    # @api public
    def uniq(&block)
      if block
        new(attributes.uniq(&block))
      else
        new(attributes.uniq(&:name))
      end
    end

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
      inferred_attrs = self.class.attributes(inferred, attr_class).
                         reject { |attr| attr_names.include?(attr.name) }

      attributes.concat(inferred_attrs)

      missing_attributes = missing - map(&:name)

      if missing_attributes.size > 0
        raise MissingAttributesError.new(name, missing_attributes)
      end

      block.call if block

      count_index
      name_index
      source_index

      freeze
    end

    # Return coercion function using attribute read types
    #
    # This is used for `output_schema` in relations
    #
    # @return [Dry::Types::Hash]
    #
    # @api private
    def to_output_hash
      Types::Coercible::Hash.schema(
        map { |attr| [attr.key, attr.to_read_type] }.to_h
      )
    end

    # Return coercion function using attribute types
    #
    # This is used for `input_schema` in relations, typically commands use it
    # for processing input
    #
    # @return [Dry::Types::Hash]
    #
    # @api private
    def to_input_hash
      Types::Coercible::Hash.schema(
        map { |attr| [attr.name, attr] }.to_h
      )
    end

    # Return a new schema with new options
    #
    # @example
    #   schema.with(inferrer: my_inferrer)
    #
    # @param [Hash] new_options
    #
    # @return [Schema]
    #
    # @api public
    def with(new_options)
      self.class.new(name, options.merge(new_options))
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
    def attr_class
      options.fetch(:attr_class)
    end

    # @api private
    def new(attributes)
      self.class.new(name, options.merge(attributes: attributes))
    end
  end
end
