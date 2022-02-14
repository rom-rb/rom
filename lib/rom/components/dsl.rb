# frozen_string_literal: true

require "rom/relation/name"

require "rom/components/dsl/gateway"
require "rom/components/dsl/dataset"
require "rom/components/dsl/schema"
require "rom/components/dsl/relation"
require "rom/components/dsl/view"
require "rom/components/dsl/association"
require "rom/components/dsl/command"
require "rom/components/dsl/mapper"

module ROM
  # This extends Configuration class with the DSL methods
  #
  # @api public
  module Components
    module DSL
      # Set or get custom dataset block
      #
      # This block will be evaluated when a relation is instantiated and registered
      # in a relation registry.
      #
      # @example
      #   class Users < ROM::Relation[:memory]
      #     dataset { sort_by(:id) }
      #   end
      #
      # @api public
      def dataset(id = nil, **options, &block)
        __dsl__(DSL::Dataset, id: id, **options, &block)
      end

      # Specify a relation schema
      #
      # With a schema defined commands will set up a type-safe input handler automatically
      #
      # @example
      #   class Users < ROM::Relation[:sql]
      #     schema do
      #       attribute :id, Types::Serial
      #       attribute :name, Types::String
      #     end
      #   end
      #
      #   # access schema from a finalized relation
      #   users.schema
      #
      # @return [Schema]
      #
      # @param [Symbol] dataset An optional dataset name
      # @param [Boolean] infer Whether to do an automatic schema inferring
      # @param [Boolean, Symbol] view Whether this is a view schema
      #
      # @api public
      def schema(id = nil, **options, &block)
        __dsl__(DSL::Schema, id: id, dataset: id, **options, &block)
      end

      # Relation definition DSL
      #
      # @example
      #   setup.relation(:users) do
      #     def names
      #       project(:name)
      #     end
      #   end
      #
      # @api public
      def relation(id, dataset: id, **options, &block)
        __dsl__(DSL::Relation, id: id, dataset: dataset, **options, &block)
      end

      # Define a relation view with a specific schema
      #
      # This method should only be used in cases where a given adapter doesn't
      # support automatic schema projection at run-time.
      #
      # @overload view(name, schema, &block)
      #   @example View with the canonical schema
      #     class Users < ROM::Relation[:sql]
      #       view(:listing, schema) do
      #         order(:name)
      #       end
      #     end
      #
      #   @example View with a projected schema
      #     class Users < ROM::Relation[:sql]
      #       view(:listing, schema.project(:id, :name)) do
      #         order(:name)
      #       end
      #     end
      #
      # @overload view(name, &block)
      #   @example View with the canonical schema and arguments
      #     class Users < ROM::Relation[:sql]
      #       view(:by_name) do |name|
      #         where(name: name)
      #       end
      #     end
      #
      #   @example View with projected schema and arguments
      #     class Users < ROM::Relation[:sql]
      #       view(:by_name) do
      #         schema { project(:id, :name) }
      #         relation { |name| where(name: name) }
      #       end
      #     end
      #
      #   @example View with a schema extended with foreign attributes
      #     class Users < ROM::Relation[:sql]
      #       view(:index) do
      #         schema { append(relations[:tasks][:title]) }
      #         relation { |name| where(name: name) }
      #       end
      #     end
      #
      # @return [Symbol] view method name
      #
      # @api public
      def view(id, *args, &block)
        __dsl__(DSL::View, id: id, args: args, &block)
        id
      end

      # Define associations for a relation
      #
      # @example
      #   class Users < ROM::Relation[:sql]
      #     associations do
      #       has_many :tasks
      #       has_many :posts
      #       has_many :posts, as: :priority_posts, view: :prioritized
      #       belongs_to :account
      #     end
      #   end
      #
      #   class Posts < ROM::Relation[:sql]
      #     associations do
      #       belongs_to :users, as: :author
      #     end
      #
      #     view(:prioritized) do
      #       where { priority <= 3 }
      #     end
      #   end
      #
      # @return [Array<Components::Association>]
      #
      # @api public
      def associations(source: config.component.id, namespace: source, **options, &block)
        __dsl__(DSL::Association, source: source, namespace: namespace, **options, &block)
        components.associations
      end

      # Command definition DSL
      #
      # @example
      #   setup.commands(:users) do
      #     define(:create) do
      #       input NewUserParams
      #       result :one
      #     end
      #
      #     define(:update) do
      #       input UserParams
      #       result :many
      #     end
      #
      #     define(:delete) do
      #       result :many
      #     end
      #   end
      #
      # @api public
      def commands(namespace, **options, &block)
        __dsl__(DSL::Command, namespace: namespace, relation: namespace, **options, &block)
        components.commands
      end

      # Mapper definition DSL
      #
      # @api public
      def mappers(namespace = nil, **options, &block)
        __dsl__(DSL::Mapper, namespace: namespace, relation: namespace, **options, &block)
        components.mappers
      end

      # Configures a plugin for a specific adapter to be enabled for all relations
      #
      # @example
      #   setup = ROM::Setup.new(:sql, 'sqlite::memory')
      #
      #   setup.plugin(:sql, relations: :instrumentation) do |p|
      #     p.notifications = MyNotificationsBackend
      #   end
      #
      #   setup.plugin(:sql, relations: :pagination)
      #
      # @param [Symbol] adapter The adapter identifier
      # @param [Hash<Symbol=>Symbol>] spec Component identifier => plugin identifier
      #
      # @return [Plugin]
      #
      # @api public
      def plugin(adapter, spec, &block)
        type, name = spec.flatten(1)

        # TODO: plugin types are singularized, so this is not consistent
        #       with the configuration DSL for plugins that uses plural
        #       names of the components - this should be unified
        plugin = ROM
          .plugins[Inflector.singularize(type)].adapter(adapter).fetch(name)
          .configure(&block)

        config.component.plugins << plugin

        plugin
      end

      # @api public
      def gateway(id, **options, &block)
        __dsl__(DSL::Gateway, id: id, **options, &block)
      end

      private

      # @api private
      def __dsl__(klass, type: klass.type, **options, &block)
        type_config = config[type].join(options, :right).inherit!(config.component)

        plugins =
          if type_config.key?(:plugins)
            type_config.plugins
          else
            EMPTY_ARRAY
          end

        type_plugins = plugins.select { |plugin| plugin.type == type }

        if klass.nested && block
          dsl = klass.new(provider: self, config: type_config)
          type_plugins.each { |plugin| plugin.enable(dsl) }
          dsl.configure
          dsl.instance_eval(&block)
          dsl
        else
          dsl = klass.new(provider: self, config: type_config, block: block)
          type_plugins.each { |plugin| plugin.enable(dsl) }
          dsl.()
        end
      end
    end
  end
end
