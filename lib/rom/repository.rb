require 'dry/core/deprecations'

require 'rom/repository/class_interface'
require 'rom/repository/mapper_builder'
require 'rom/repository/relation_proxy'
require 'rom/repository/command_compiler'

require 'rom/repository/root'
require 'rom/repository/changeset'
require 'rom/repository/transaction'

module ROM
  # Abstract repository class to inherit from
  #
  # A repository provides access to composable relations and commands. Its job is
  # to provide application-specific data that is already materialized, so that
  # relations don't leak into your application layer.
  #
  # Typically, you're going to work with Repository::Root that are configured to
  # use a single relation as its root, and compose aggregates and use commands
  # against the root relation.
  #
  # @example
  #   class MyRepo < ROM::Repository[:users]
  #     relations :users, :tasks
  #
  #     def users_with_tasks
  #       users.combine_children(tasks: tasks).to_a
  #     end
  #   end
  #
  #   rom = ROM.container(:sql, 'sqlite::memory') do |conf|
  #     conf.default.create_table(:users) do
  #       primary_key :id
  #       column :name, String
  #     end
  #
  #     conf.default.create_table(:tasks) do
  #       primary_key :id
  #       column :user_id, Integer
  #       column :title, String
  #     end
  #   end
  #
  #   my_repo = MyRepo.new(rom)
  #   my_repo.users_with_tasks
  #
  # @see Repository::Root
  #
  # @api public
  class Repository
    # @deprecated
    class Base < Repository
      def self.inherited(klass)
        super
        Dry::Core::Deprecations.announce(self, 'inherit from Repository instead', tag: :rom)
      end
    end

    extend ClassInterface

    # @!attribute [r] container
    #   @return [ROM::Container] The container used to set up a repo
    attr_reader :container

    # @!attribute [r] relations
    #   @return [RelationRegistry] The relation proxy registry used by a repo
    attr_reader :relations

    # @!attribute [r] mappers
    #   @return [MapperBuilder] The auto-generated mappers for repo relations
    attr_reader :mappers

    # Initializes a new repo by establishing configured relation proxies from
    # the passed container
    #
    # @param container [ROM::Container] The rom container with relations and optional commands
    #
    # @api public
    def initialize(container)
      @container = container
      @mappers = MapperBuilder.new
      @relations = RelationRegistry.new do |registry, relations|
        self.class.relations.each do |name|
          relation = container.relation(name)

          proxy = RelationProxy.new(
            relation, name: name, mappers: mappers, registry: registry
          )

          instance_variable_set("@#{name}", proxy)

          relations[name] = proxy
        end
      end
    end

    # @overload command(type, relation)
    #   Returns a command for a relation
    #
    #   @example
    #     repo.command(:create, repo.users)
    #
    #   @param type [Symbol] The command type (:create, :update or :delete)
    #   @param relation [RelationProxy] The relation for which command should be built for
    #
    # @overload command(options)
    #   Builds a command for a given relation identifier
    #
    #   @example
    #     repo.command(create: :users)
    #
    #   @param options [Hash<Symbol=>Symbol>] A type => rel_name map
    #
    # @overload command(rel_name)
    #   Returns command registry for a given relation identifier
    #
    #   @example
    #     repo.command(:users)[:my_custom_command]
    #
    #   @param rel_name [Symbol] The relation identifier from the container
    #
    #   @return [CommandRegistry]
    #
    # @overload command(rel_name, &block)
    #   Yields a command graph composer for a given relation identifier
    #
    #   @param rel_name [Symbol] The relation identifier from the container
    #
    # @return [ROM::Command]
    #
    # @api public
    def command(*args, **opts, &block)
      all_args = args + opts.to_a.flatten

      if all_args.size > 1
        commands.fetch_or_store(all_args.hash) do
          compile_command(*args, **opts)
        end
      else
        container.command(*args, &block)
      end
    end

    # @overload changeset(name, attributes)
    #   Returns a create changeset for a given relation identifier
    #
    #   @example
    #     repo.changeset(:users, name: "Jane")
    #
    #   @param name [Symbol] The relation container identifier
    #   @param attributes [Hash]
    #
    #   @return [Changeset::Create]
    #
    # @overload changeset(name, restriction_arg, attributes)
    #   Returns an update changeset for a given relation identifier
    #
    #   @example
    #     repo.changeset(:users, 1, name: "Jane Doe")
    #
    #   @param name [Symbol] The relation container identifier
    #   @param restriction_arg [Object] The argument passed to restricted view
    #
    #   @return [Changeset::Update]
    #
    # @api public
    def changeset(*args)
      if args.size == 2
        name, data = args
      elsif args.size == 3
        name, pk, data = args
      else
        raise ArgumentError, 'Repository#changeset accepts 2 or 3 arguments'
      end

      relation = relations[name]

      if pk
        Changeset::Update.new(relation, data, primary_key: pk)
      else
        Changeset::Create.new(relation, data)
      end
    end

    # TODO: document me, please
    #
    # @api public
    def transaction(&block)
      yield(Transaction.new(self)).commit!
    end

    private

    # Local command cache
    #
    # @api private
    def commands
      @__commands__ ||= Concurrent::Map.new
    end

    # Build a new command or return existing one
    #
    # @api private
    def compile_command(*args, mapper: nil, use: nil, **opts)
      type, name = args + opts.to_a.flatten(1)

      relation = name.is_a?(Symbol) ? relations[name] : name

      ast = relation.to_ast
      adapter = relations[relation.name].adapter

      if mapper
        mapper_instance = container.mappers[relation.name.relation][mapper]
      else
        mapper_instance = mappers[ast]
      end

      command = CommandCompiler[container, type, adapter, ast, use]
      command >> mapper_instance
    end

    # @api private
    def map_tuple(relation, tuple)
      relations[relation.name].mapper.([tuple]).first
    end
  end
end
