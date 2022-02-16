# frozen_string_literal: true


require "dry/core/memoizable"
require "dry/core/class_attributes"

require "rom/support/configurable"
require "rom/struct"
require "rom/constants"
require "rom/initializer"
require "rom/support/inflector"

require "rom/plugins/class_methods"
require "rom/relation/class_interface"

require "rom/auto_curry"
require "rom/pipeline"

require "rom/relation/loaded"
require "rom/relation/curried"
require "rom/relation/commands"
require "rom/relation/composite"
require "rom/relation/combined"
require "rom/relation/wrap"
require "rom/relation/materializable"

require "rom/types"

require_relative "registries/root"
require_relative "components/provider"

module ROM
  # Base relation class
  #
  # Relation is a proxy for the dataset object provided by the gateway. It
  # can forward methods to the dataset, which is why the "native" interface of
  # the underlying gateway is available in the relation
  #
  # Individual adapters sets up their relation classes and provide different APIs
  # depending on their persistence backend.
  #
  # @api public
  class Relation
    extend ROM::Provider(:dataset, :schema, :view, :association, type: :relation)
    extend Plugins::ClassMethods
    extend Initializer
    extend ClassInterface

    include Dry::Core::Memoizable
    include Relation::Commands

    # Default no-op output schema which is called in `Relation#each`
    NOOP_OUTPUT_SCHEMA = -> tuple { tuple }.freeze

    setting :auto_map, default: true
    setting :auto_struct, default: false
    setting :struct_namespace, default: ROM::Struct
    setting :wrap_class, default: Relation::Wrap

    # @api private
    def self.inherited(klass)
      super

      adapter = config.component.adapter

      klass.configure do |config|
        # Relations that inherit from an adapter subclass are not considered abstract anymore
        # You can override it later inside your class' config of course
        if adapter
          config.component.abstract = false

          # Use klass' name to set defaults
          #
          # ie `Relations::Users` assumes :users id and a corresponding dataset (table in case of SQL)
          #
          # TODO: make this behavior configurable?
          #
          if klass.name
            config.component.id = config.component.inflector.component_id(klass.name).to_sym
            config.component.dataset = config.component.id
          else
            config.component.id = :anonymous
          end
        end
      end
    end

    include Dry::Equalizer(:name, :dataset)
    include Materializable
    include Pipeline

    # @!attribute [r] config
    #   @return [Dry::Configurable::Config]
    #   @api private
    option :config, default: -> { self.class.config }

    # @!attribute [r] name
    #   @return [Name] The relation name
    #   @api public
    option :name, default: -> { Name[config.component.id, config.component.dataset] }

    # @!attribute [r] registry
    #   @return [registry] Registry::Root with runtime dependency resolving
    option :registry, default: -> { self.class.registry(config: config) }

    # @!attribute [r] inflector
    #   @return [Dry::Inflector] The default inflector
    #   @api public
    option :inflector, default: -> { config.component.inflector }

    # @!attribute [r] schemas
    #   @return [Setup::registry] Relation schemas
    option :schemas, default: -> { registry.schemas.scoped(config.component.id, config: config) }

    # @!attribute [r] schema
    #   @return [Setup::registry] The canonical schema
    option :schema, default: -> { schemas.infer(config.component.id) }

    # @!attribute [r] datasets
    #   @return [registry] Relation associations
    option :datasets, default: -> { registry.datasets.scoped(config.component.id, config: config) }

    # @!attribute [r] dataset
    #   @return [Object] dataset used by the relation provided by relation's gateway
    #   @api public
    option :dataset, default: -> { datasets.infer(config.component.id) }

    # @!attribute [r] associations
    #   @return [Setup::registry] Relation associations
    option :associations, default: -> { registry.associations.scoped(config.component.id) }

    # @!attribute [r] input_schema
    #   @return [Object#[]] tuple processing function, uses schema or defaults to Hash[]
    #   @api private
    option :input_schema, default: -> { schema.to_input_hash }

    # @!attribute [r] output_schema
    #   @return [Object#[]] tuple processing function, uses schema or defaults to NOOP_OUTPUT_SCHEMA
    #   @api private
    option :output_schema, default: lambda {
      schema.any?(&:read?) ? schema.to_output_hash : NOOP_OUTPUT_SCHEMA
    }

    # @!attribute [r] auto_map
    #   @return [TrueClass,FalseClass] Whether or not a relation and its compositions should be auto-mapped
    #   @api private
    option :auto_map, default: -> { config.auto_map }

    # @!attribute [r] auto_struct
    #   @return [TrueClass,FalseClass] Whether or not tuples should be auto-mapped to structs
    #   @api private
    option :auto_struct, default: -> { config.auto_struct }

    # @!attribute [r] struct_namespace
    #   @return [Module] Custom struct namespace
    #   @api private
    option :struct_namespace, reader: false, default: -> { config.struct_namespace }

    # @!attribute [r] mappers
    #   @return [registry] an optional mapper registry (empty by default)
    option :mappers, default: -> do
      registry.mappers.scoped(config.component.id, opts: {adapter: adapter})
    end

    # @!attribute [r] commands
    #   @return [Commandregistry] Command registry
    #   @api private
    option :commands, default: -> do
      registry.commands.scoped(config.component.id, opts: {adapter: adapter})
    end

    # @!attribute [r] meta
    #   @return [Hash] Meta data stored in a hash
    #   @api private
    option :meta, reader: true, default: -> { EMPTY_HASH }

    # @api public
    def self.new(dataset = nil, **opts)
      if dataset
        super(**opts, dataset: dataset)
      else
        super(**opts)
      end
    end

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
    # @return [Attribute]
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
      return to_enum unless block_given?

      if auto_map?
        mapper.(dataset.map { |tuple| output_schema[tuple] }).each(&block)
      else
        dataset.each { |tuple| yield(output_schema[tuple]) }
      end
    end

    # Combine with other relations using configured associations
    #
    # @overload combine(*associations)
    #   @example
    #     users.combine(:tasks, :posts)
    #
    #   @param *associations [Array<Symbol>] A list of association names
    #
    # @overload combine(*associations, **nested_associations)
    #   @example
    #     users.combine(:tasks, posts: :authors)
    #
    #   @param *associations [Array<Symbol>] A list of association names
    #   @param *nested_associations [Hash] A hash with nested association names
    #
    # @overload combine(associations)
    #   @example
    #     users.combine(posts: [:authors, reviews: [:tags, comments: :author])
    #
    #   @param *associations [Hash] A hash with nested association names
    #
    # @return [Relation]
    #
    # @api public
    def combine(*args)
      combine_with(*nodes(*args))
    end

    # Composes with other relations
    #
    # @param [Array<Relation>] others The other relation(s) to compose with
    #
    # @return [Relation::Graph]
    #
    # @api public
    def combine_with(*others)
      Combined.new(self, others)
    end

    # @api private
    def nodes(*args)
      args.reduce([]) do |acc, arg|
        case arg
        when Symbol
          acc << node(arg)
        when Hash
          acc.concat(arg.map { |name, opts| node(name).combine(opts) })
        when Array
          acc.concat(arg.map { |opts| nodes(opts) }.reduce(:concat))
        end
      end
    end

    # Create a graph node for a given association identifier
    #
    # @param [Symbol, Relation::Name] name
    #
    # @return [Relation]
    #
    # @api public
    def node(name)
      assoc = associations[name]
      other = assoc.node
      other.eager_load(assoc)
    end

    # Return a graph node prepared by the given association
    #
    # @param [Association] assoc An association object
    #
    # @return [Relation]
    #
    # @api public
    def eager_load(assoc)
      relation = assoc.prepare(self)

      if assoc.override?
        relation.(assoc)
      else
        relation.preload_assoc(assoc)
      end
    end

    # Preload other relation via association
    #
    # This is used internally when relations are composed
    #
    # @return [Relation::Curried]
    #
    # @api private
    def preload_assoc(assoc, other)
      assoc.preload(self, other)
    end

    # Wrap other relations using association names
    #
    # @example
    #   tasks.wrap(:owner)
    #
    # @param [Array<Symbol>] names A list with association identifiers
    #
    # @return [Wrap]
    #
    # @api public
    def wrap(*names)
      wrap_around(*names.map { |n| associations[n].wrap })
    end

    # Wrap around other relations
    #
    # @param [Array<Relation>] others Other relations
    #
    # @return [Relation::Wrap]
    #
    # @api public
    def wrap_around(*others)
      wrap_class.new(self, others)
    end

    # Loads a relation
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

    # Return if this is a wrap relation
    #
    # @return [false]
    #
    # @api private
    def wrap?
      false
    end

    # Returns true if a relation has schema defined
    #
    # @return [TrueClass, FalseClass]
    #
    # @api private
    def schema?
      !schema.empty?
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
    def new(dataset, **new_opts)
      opts =
        if new_opts.empty?
          options
        elsif new_opts.key?(:schema)
          options.merge(new_opts).reject { |k, _| k == :input_schema || k == :output_schema }
        else
          options.merge(new_opts)
        end

      self.class.new(**opts, dataset: dataset)
    end

    undef_method :with

    # Returns a new instance with the same dataset but new options
    #
    # @example
    #   users.with(output_schema: -> tuple { .. })
    #
    # @param [Hash] opts New options
    #
    # @return [Relation]
    #
    # @api public
    def with(opts)
      new_options =
        if opts.key?(:meta)
          opts.merge(meta: meta.merge(opts[:meta]))
        else
          opts
        end

      new(dataset, **options, **new_options)
    end

    # Returns AST for the wrapped relation
    #
    # @return [Array]
    #
    # @api public
    def to_ast
      [:relation, [name.relation, attr_ast, meta_ast]]
    end

    # @api private
    def attr_ast
      schema.map(&:to_read_ast)
    end

    # @api private
    def meta_ast
      meta = self.meta.merge(dataset: name.dataset, alias: name.aliaz,
                             struct_namespace: options[:struct_namespace])
      meta[:model] = false unless auto_struct? || meta[:model]
      meta
    end

    # @api private
    def auto_map?
      (auto_map || auto_struct) && !meta[:combine_type]
    end

    # @api private
    def auto_struct?
      auto_struct && !meta[:combine_type]
    end

    # @api private
    def mapper
      mappers[to_ast]
    end

    # Maps relation with custom mappers available via registry
    #
    # When `auto_map` is enabled, your mappers will be applied after performing
    # default auto-mapping. This means that you can compose complex relations
    # and have them auto-mapped, and use much simpler custom mappers to adjust
    # resulting data according to your requirements.
    #
    # @overload map_with(*mappers)
    #   Map tuples using registered mappers
    #
    #   @example
    #     users.map_with(:my_mapper, :my_other_mapper)
    #
    #   @param [Array<Symbol>] mappers A list of mapper identifiers
    #
    # @overload map_with(*mappers, auto_map: true)
    #   Map tuples using custom registered mappers and enforce auto-mapping
    #
    #   @example
    #     users.map_with(:my_mapper, :my_other_mapper, auto_map: true)
    #
    #   @param [Array<Symbol>] mappers A list of mapper identifiers
    #
    # @return [Relation::Composite] Mapped relation
    #
    # @api public
    def map_with(*names, **opts)
      super(*names).with(opts)
    end

    # Return a new relation that will map its tuples to instances of the provided class
    #
    # @example
    #   users.map_to(MyUserModel)
    #
    # @param [Class] klass Your custom model class
    #
    # @return [Relation]
    #
    # @api public
    def map_to(klass, **opts)
      with(opts.merge(auto_map: false, auto_struct: true, meta: {model: klass}))
    end

    # Return a new relation with an aliased name
    #
    # @example
    #   users.as(:people)
    #
    # @param [Symbol] aliaz Aliased name
    #
    # @return [Relation]
    #
    # @api public
    def as(aliaz)
      with(name: name.as(aliaz))
    end

    # @return [Symbol] The wrapped relation's adapter identifier ie :sql or :http
    #
    # @api private
    def adapter
      config.component.adapter
    end

    # Return name of the source gateway of this relation
    #
    # @return [Symbol]
    #
    # @api private
    def gateway
      config.component.gateway
    end

    # Return a foreign key name for the provided relation name
    #
    # @param [Name] name The relation name object
    #
    # @return [Symbol]
    #
    # @api private
    def foreign_key(name)
      attr = schema.foreign_key(name.dataset)

      if attr
        attr.name
      else
        :"#{inflector.singularize(name.dataset)}_id"
      end
    end

    # Return a new relation configured with the provided struct namespace
    #
    # @param [Module] ns Custom namespace module for auto-structs
    #
    # @return [Relation]
    #
    # @api public
    def struct_namespace(ns)
      options[:struct_namespace] == ns ? self : with(struct_namespace: ns)
    end

    memoize :to_ast, :auto_map?, :auto_struct?, :foreign_key, :combine, :wrap, :node

    # we do it here because we want to avoid previous methods to be auto_curried
    # via method_added hook, which is what AutoCurry uses
    extend AutoCurry

    auto_curry :preload_assoc

    private

    # Hook used by `Pipeline` to get the class that should be used for composition
    #
    # @return [Class]
    #
    # @api private
    def composite_class
      Relation::Composite
    end

    # Return configured "wrap" relation class used in Relation#wrap
    #
    # @return [Class]
    #
    # @api private
    def wrap_class
      config.wrap_class
    end
  end
end
