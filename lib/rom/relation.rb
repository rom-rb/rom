require 'rom/initializer'
require 'rom/relation/class_interface'

require 'rom/pipeline'
require 'rom/mapper_registry'

require 'rom/relation/loaded'
require 'rom/relation/curried'
require 'rom/relation/composite'
require 'rom/relation/graph'
require 'rom/relation/materializable'
require 'rom/association_set'

require 'rom/types'
require 'rom/schema'

module ROM
  # Base relation class
  #
  # Relation is a proxy for the dataset object provided by the gateway. It
  # can forward methods to the dataset, which is why the "native" interface of
  # the underlying gateway is available in the relation. This interface,
  # however, is considered private and should not be used outside of the
  # relation instance.
  #
  # Individual adapters sets up their relation classes and provide different APIs
  # depending on their persistence backend.
  #
  # Vanilla Relation class doesn't have APIs that are specific to ROM container setup.
  # When adapter Relation class inherits from this class, these APIs are added automatically,
  # so that they can be registered within a container.
  #
  # @see ROM::Relation::ClassInterface
  #
  # @api public
  class Relation
    # Default no-op output schema which is called in `Relation#each`
    NOOP_OUTPUT_SCHEMA = -> tuple { tuple }.freeze

    extend Initializer
    extend ClassInterface

    include Dry::Equalizer(:dataset)
    include Materializable
    include Pipeline

    # @!attribute [r] dataset
    #   @return [Object] dataset used by the relation provided by relation's gateway
    #   @api public
    param :dataset

    # @!attribute [r] mappers
    #   @return [MapperRegistry] an optional mapper registry (empty by default)
    option :mappers, reader: true, default: -> { MapperRegistry.new }

    # @!attribute [r] schema
    #   @return [Schema] relation schema, defaults to class-level canonical
    #                    schema (if it was defined) and sets an empty one as
    #                    the fallback
    #   @api public
    option :schema, reader: true, optional: true, default: -> { self.class.default_schema(self) }

    # @!attribute [r] input_schema
    #   @return [Object#[]] tuple processing function, uses schema or defaults to Hash[]
    #   @api private
    option :input_schema, reader: true, default: -> { schema? ? schema.to_input_hash : Hash }

    # @!attribute [r] output_schema
    #   @return [Object#[]] tuple processing function, uses schema or defaults to NOOP_OUTPUT_SCHEMA
    #   @api private
    option :output_schema, reader: true, optional: true, default: -> {
      schema.any?(&:read?) ? schema.to_output_hash : NOOP_OUTPUT_SCHEMA
    }

    # Return schema attribute
    #
    # @example accessing canonical attribute
    #   users[:id]
    #   # => #<ROM::SQL::Attribute[Integer] primary_key=true name=:id source=ROM::Relation::Name(users)>
    #
    # @example accessing joined attribute
    #   tasks_with_users = tasks.join(users).select_append(tasks[:title])
    #   tasks_with_users[:title, :tasks]
    #   # => #<ROM::SQL::Attribute[String] primary_key=false name=:title source=ROM::Relation::Name(tasks)>
    #
    # @return [Schema::Attribute]
    #
    # @api public
    def [](name)
      schema[name]
    end

    # Yields relation tuples
    #
    # Every tuple is processed through Relation#output_schema, it's a no-op by default
    #
    # @yield [Hash]
    #
    # @return [Enumerator] if block is not provided
    #
    # @api public
    def each(&block)
      return to_enum unless block
      dataset.each { |tuple| yield(output_schema[tuple]) }
    end

    # Composes with other relations
    #
    # @param [Array<Relation>] others The other relation(s) to compose with
    #
    # @return [Relation::Graph]
    #
    # @api public
    def combine(*others)
      Graph.build(self, others)
    end

    # Loads relation
    #
    # @return [Relation::Loaded]
    #
    # @api public
    def call
      Loaded.new(self)
    end

    # Materializes a relation into an array
    #
    # @return [Array<Hash>]
    #
    # @api public
    def to_a
      to_enum.to_a
    end

    # Returns if this relation is curried
    #
    # @return [false]
    #
    # @api private
    def curried?
      false
    end

    # Returns if this relation is a graph
    #
    # @return [false]
    #
    # @api private
    def graph?
      false
    end

    # Returns true if a relation has schema defined
    #
    # @return [TrueClass, FalseClass]
    #
    # @api private
    def schema?
      ! schema.empty?
    end

    # Return a new relation with provided dataset and additional options
    #
    # Use this method whenever you need to use dataset API to get a new dataset
    # and you want to return a relation back. Typically relation API should be
    # enough though. If you find yourself using this method, it might be worth
    # to consider reporting an issue that some dataset functionality is not available
    # through relation API.
    #
    # @example with a new dataset
    #   users.new(users.dataset.some_method)
    #
    # @example with a new dataset and options
    #   users.new(users.dataset.some_method, other: 'options')
    #
    # @param [Object] dataset
    # @param [Hash] new_opts Additional options
    #
    # @api public
    def new(dataset, new_opts = EMPTY_HASH)
      self.class.new(dataset, new_opts.empty? ? options : options.merge(new_opts))
    end

    # Returns a new instance with the same dataset but new options
    #
    # @example
    #   users.with(output_schema: -> tuple { .. })
    #
    # @param new_options [Hash]
    #
    # @return [Relation]
    #
    # @api private
    def with(new_options)
      new(dataset, options.merge(new_options))
    end

    # Return all registered relation schemas
    #
    # This holds all schemas defined via `view` DSL
    #
    # @return [Hash<Symbol=>Schema>]
    #
    # @api public
    def schemas
      @schemas ||= self.class.schemas
    end

    # Return schema's association set (empty by default)
    #
    # @return [AssociationSet] Schema's association set (empty by default)
    #
    # @api public
    def associations
      @associations ||= schema.associations
    end

    private

    # Hook used by `Pipeline` to get the class that should be used for composition
    #
    # @return [Class]
    #
    # @api private
    def composite_class
      Relation::Composite
    end
  end
end
