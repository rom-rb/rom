require 'dry/core/deprecations'

require 'rom/repository/class_interface'
require 'rom/repository/mapper_builder'
require 'rom/repository/relation_proxy'
require 'rom/repository/command_compiler'

require 'rom/repository/root'
require 'rom/repository/changeset'
require 'rom/repository/session'

module ROM
  # Abstract repository class to inherit from
  #
  # A repository provides access to composable relations, commands and changesets.
  # Its job is to provide application-specific data that is already materialized, so that
  # relations don't leak into your application layer.
  #
  # Typically, you're going to work with Repository::Root that is configured to
  # use a single relation as its root, and compose aggregates and use changesets and commands
  # against the root relation.
  #
  # @example
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
  #
  #     conf.relation(:users) do
  #       associations do
  #         has_many :tasks
  #       end
  #     end
  #   end
  #
  #   class UserRepo < ROM::Repository[:users]
  #     relations :tasks
  #
  #     def users_with_tasks
  #       aggregate(:tasks).to_a
  #     end
  #   end
  #
  #   user_repo = UserRepo.new(rom)
  #   user_repo.users_with_tasks
  #
  # @see Repository::Root
  #
  # @api public
  class Repository
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

    # @!attribute [r] commmand_compiler
    #   @return [Method] Function for compiling commands bound to a repo instance
    attr_reader :command_compiler

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
      @command_compiler = method(:command)
    end

    # Return a command for a relation
    #
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

    # Return a changeset for a relation
    #
    # @overload changeset(name, attributes)
    #   Return a create changeset for a given relation identifier
    #
    #   @example
    #     repo.changeset(:users, name: "Jane")
    #
    #   @param name [Symbol] The relation container identifier
    #   @param attributes [Hash]
    #
    #   @return [Changeset::Create]
    #
    # @overload changeset(name, primary_key, attributes)
    #   Return an update changeset for a given relation identifier
    #
    #   @example
    #     repo.changeset(:users, 1, name: "Jane Doe")
    #
    #   @param name [Symbol] The relation container identifier
    #   @param restriction_arg [Object] The argument passed to restricted view
    #
    #   @return [Changeset::Update]
    #
    # @overload changeset(changeset_class)
    #   Return a changeset object using provided class
    #
    #   @example
    #     repo.changeset(NewUserChangeset).data(attributes)
    #
    #   @param [Class] changeset_class Custom changeset class
    #
    #   @return [Changeset]
    #
    # @overload changeset(opts)
    #   Return a changeset object using provided changeset type and relation
    #
    #   @example
    #     repo.changeset(delete: repo.users.where { id > 10 })
    #
    #   @param [Hash<Symbol=>Relation] opts Command type => Relation config
    #
    #   @return [Changeset]
    #
    # @api public
    def changeset(*args)
      opts = { command_compiler: command_compiler }

      if args.size == 2
        name, data = args
      elsif args.size == 3
        name, pk, data = args
      elsif args.size == 1
        type = args[0]

        if type.is_a?(Class) && type < Changeset
          return type.new(relations[type.relation], opts)
        else
          type, relation = args[0].to_a[0]
        end
      else
        raise ArgumentError, 'Repository#changeset accepts 1-3 arguments'
      end

      if type
        if type.equal?(:delete)
          Changeset::Delete.new(relation, opts)
        end
      else
        relation = relations[name]

        if pk
          Changeset::Update.new(relation.by_pk(pk), opts.update(__data__: data))
        else
          Changeset::Create.new(relation, opts.update(__data__: data))
        end
      end
    end

    # Open a database transaction
    #
    # @example commited transaction
    #   user = transaction do |t|
    #     create(changeset(name: 'Jane'))
    #   end
    #
    #   user
    #   # => #<ROM::Struct[User] id=1 name="Jane">
    #
    # @example with a rollback
    #   user = transaction do |t|
    #     changeset(name: 'Jane').commit
    #     t.rollback!
    #   end
    #
    #   user
    #   # nil
    #
    # @api public
    def transaction(&block)
      container.gateways[:default].transaction(&block)
    end

    # Return a string representation of a repository object
    #
    # @return [String]
    #
    # @api public
    def inspect
      %(#<#{self.class} relations=[#{self.class.relations.map(&:inspect).join(' ')}]>)
    end

    # Start a session for multiple changesets
    #
    # TODO: this is partly done, needs tweaks in changesets so that we can gather
    #       command results and return them in a nice way
    #
    # @!visibility private
    #
    # @api public
    def session(&block)
      session = Session.new(self)
      yield(session)
      transaction { session.commit! }
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
      elsif mapper.nil?
        mapper_instance = mappers[ast]
      end

      command = CommandCompiler[container, type, adapter, ast, use, opts]

      if mapper_instance
        command >> mapper_instance
      else
        command.new(relation)
      end
    end

    # @api private
    def map_tuple(relation, tuple)
      relations[relation.name].mapper.([tuple]).first
    end
  end
end
