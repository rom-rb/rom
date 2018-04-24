require 'dry/equalizer'

require 'rom/constants'
require 'rom/attribute'
require 'rom/schema/dsl'
require 'rom/schema/inferrer'
require 'rom/association_set'
require 'rom/support/notifications'
require 'rom/support/memoizable'

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
    include Memoizable

    extend Notifications::Listener

    subscribe('configuration.relations.registry.created') do |event|
      registry = event[:registry]

      registry.each do |_, relation|
        unless relation.schema.frozen?
          relation.schema.finalize_associations!(relations: registry)
          relation.schema.finalize!
        end
      end
    end

    subscribe('configuration.relations.schema.allocated') do |event|
      schema = event[:schema]
      registry = event[:registry]
      gateway = event[:gateway]

      unless schema.frozen?
        schema.finalize_attributes!(gateway: gateway, relations: registry)
        schema.set!(:relations, registry)
      end
    end

    EMPTY_ASSOCIATION_SET = AssociationSet.new(EMPTY_HASH).freeze

    DEFAULT_INFERRER = Inferrer.new(enabled: false).freeze

    type_transformation = -> type, _ do
      t = if type.default?
            type.constructor { |value| value.nil? ? Undefined : value }
          else
            type
          end
      t.meta(omittable: true)
    end

    HASH_SCHEMA = Types::Coercible::Hash.
                    schema(EMPTY_HASH).
                    with_type_transform(type_transformation)

    extend Initializer

    include Dry::Equalizer(:name, :attributes, :associations)
    include Enumerable

    # @!attribute [r] name
    #   @return [Symbol] The name of this schema
    param :name

    # @!attribute [r] attributes
    #   @return [Array] Array with schema attributes
    option :attributes, default: -> { EMPTY_ARRAY }

    # @!attribute [r] associations
    #   @return [AssociationSet] Optional association set (this is adapter-specific)
    option :associations, default: -> { EMPTY_ASSOCIATION_SET }

    # @!attribute [r] inferrer
    #   @return [#call] An optional inferrer object used in `finalize!`
    option :inferrer, default: -> { DEFAULT_INFERRER }

    # @api private
    option :relations, default: -> { EMPTY_HASH }

    # @!attribute [r] canonical
    #   @return [Symbol] The canonical schema which is carried in all schema instances
    option :canonical, default: -> { self }

    # @api private
    option :attr_class, default: -> { Attribute }

    # @!attribute [r] primary_key_name
    #   @return [Symbol] The name of the primary key. This is set because in
    #                    most of the cases relations don't have composite pks
    option :primary_key_name, optional: true

    # @!attribute [r] primary_key_names
    #   @return [Array<Symbol>] A list of all pk names
    option :primary_key_names, optional: true

    alias_method :to_ary, :attributes

    # Define a relation schema from plain rom types
    #
    # Resulting schema will decorate plain rom types with adapter-specific types
    # By default `Attribute` will be used
    #
    # @param [Relation::Name, Symbol] name The schema name, typically ROM::Relation::Name
    #
    # @return [Schema]
    #
    # @api public
    def self.define(name, attributes: EMPTY_ARRAY, attr_class: Attribute, **options)
      new(
        name,
        attr_class: attr_class,
        attributes: attributes(attributes, attr_class),
        **options
      ) { |schema| yield(schema) if block_given? }
    end

    # @api private
    def self.attributes(attributes, attr_class)
      attributes.map { |type| attr_class.new(type) }
    end

    # @api private
    def initialize(*)
      super

      yield(self) if block_given?
    end

    # Abstract method for creating a new relation based on schema definition
    #
    # This can be used by views to generate a new relation automatically.
    # In example a schema can project a relation, join any additional relations
    # if it includes attributes from other relations etc.
    #
    # Default implementation is a no-op and it simply returns back untouched relation
    #
    # @param [Relation] relation
    #
    # @return [Relation]
    #
    # @api public
    def call(relation)
      relation
    end

    # Iterate over schema's attributes
    #
    # @yield [Attribute]
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
    # @param [*Array<Symbol, Attribute>] names Attribute names
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
    # @return [Attribute]
    #
    # @api public
    def foreign_key(relation)
      detect { |attr| attr.foreign_key? && attr.target == relation }
    end

    # Return primary key attributes
    #
    # @return [Array<Attribute>]
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
    # @param [Array<Attribute>] new_attributes
    #
    # @return [Schema]
    #
    # @api public
    def append(*new_attributes)
      new(attributes + new_attributes)
    end

    # Return a new schema with uniq attributes
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

    # Return if a schema is canonical
    #
    # @return [Boolean]
    #
    # @api public
    def canonical?
      self.equal?(canonical)
    end

    # Finalize a schema
    #
    # @return [self]
    #
    # @api private
    def finalize!(**opts)
      return self if frozen?
      freeze
    end

    # This hook is called when relation is being build during container finalization
    #
    # When block is provided it'll be called just before freezing the instance
    # so that additional ivars can be set
    #
    # @return [self]
    #
    # @api private
    def finalize_attributes!(gateway: nil, relations: nil)
      inferrer.(self, gateway).each { |key, value| set!(key, value) }

      yield if block_given?

      initialize_primary_key_names

      self
    end

    # Finalize associations defined in a schema
    #
    # @param [RelationRegistry] relations
    #
    # @return [self]
    #
    # @api private
    def finalize_associations!(relations:)
      set!(:associations, yield) if associations.any?
      self
    end

    # Return coercion function using attribute read types
    #
    # This is used for `output_schema` in relations
    #
    # @return [Dry::Types::Hash]
    #
    # @api private
    def to_output_hash
      HASH_SCHEMA.schema(
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
      HASH_SCHEMA.schema(
        map { |attr| [attr.name, attr.to_write_type] }.to_h
      )
    end

    # Return AST for the schema
    #
    # @return [Array]
    #
    # @api public
    def to_ast
      [:schema, [name, attributes.map(&:to_ast)]]
    end

    # @api private
    def set!(key, value)
      instance_variable_set("@#{ key }", value)
      options[key] = value
    end

    private

    # @api private
    def count_index
      map(&:name).map { |name| [name, count { |attr| attr.name == name }] }.to_h
    end

    # @api private
    def name_index
      map { |attr| [attr.name, attr] }.to_h
    end

    # @api private
    def source_index
      select(&:source).
        group_by(&:source).
        map { |src, grp| [src.to_sym, grp.map { |attr| [attr.name, attr] }.to_h] }.
        to_h
    end

    # @api private
    def new(attributes)
      self.class.new(name, **options, attributes: attributes)
    end

    # @api private
    def initialize_primary_key_names
      if primary_key.size > 0
        set!(:primary_key_name, primary_key[0].meta[:name])
        set!(:primary_key_names, primary_key.map { |type| type.meta[:name] })
      end
    end

    memoize :count_index, :name_index, :source_index, :to_ast, :to_input_hash, :to_output_hash
  end
end
