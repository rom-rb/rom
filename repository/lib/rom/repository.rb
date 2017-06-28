require 'dry/core/deprecations'

require 'rom/initializer'
require 'rom/repository/class_interface'
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
    extend Initializer
    extend Dry::Core::ClassAttributes

    # @!method self.auto_struct
    #   Get or set auto_struct setting
    #
    #   When disabled, rom structs won't be created
    #
    #   @overload auto_struct
    #     Return auto_struct setting value
    #     @return [TrueClass,FalseClass]
    #
    #   @overload auto_struct(value)
    #     Set auto_struct value
    #     @return [Class]
    defines :auto_struct

    auto_struct true

    # @!method self.auto_struct
    #   Get or set struct namespace
    defines :struct_namespace

    # @!method self.relation_reader
    #   Get or set relation reader module
    #   @return [RelationReader]
    defines :relation_reader

    struct_namespace ROM::Struct

    # @!attribute [r] container
    #   @return [ROM::Container] The container used to set up a repo
    param :container, allow: ROM::Container

    # @!attribute [r] struct_namespace
    #   @return [Module,Class] The namespace for auto-generated structs
    option :struct_namespace, default: -> { self.class.struct_namespace }

    # @!attribute [r] auto_struct
    #   @return [Boolean] The container used to set up a repo
    option :auto_struct, default: -> { self.class.auto_struct }

    # @!attribute [r] relations
    #   @return [RelationRegistry] The relation proxy registry used by a repo
    attr_reader :relations

    # Initializes a new repo by establishing configured relation proxies from
    # the passed container
    #
    # @param container [ROM::Container] The rom container with relations and optional commands
    #
    # @api private
    def initialize(container, options = EMPTY_HASH)
      super
      @relations = {}
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
      compile_command(*args, **opts)
    end

    # Open a database transaction
    #
    # @example commited transaction
    #   user = transaction do |t|
    #     create(changeset(name: 'Jane'))
    #   end
    #
    #   user
    #   # => #<ROM::Struct::User id=1 name="Jane">
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
      %(#<#{self.class} struct_namespace=#{struct_namespace} auto_struct=#{auto_struct}>)
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

    # Registered commands
    #
    # @api private
    def commands
      container.commands
    end

    private

    # Build a new command or return existing one
    #
    # @api private
    def compile_command(*args, mapper: nil, use: EMPTY_ARRAY, **opts)
      type, name = args + opts.to_a.flatten(1)
      relation = name.is_a?(Symbol) ? relations[name] : name

      relation.command(type, mapper: mapper, use: use, **opts)
    end
  end
end

require 'rom/repository/root'
