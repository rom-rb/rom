# frozen_string_literal: true

require "rom/initializer"
require "rom/plugins"
require "rom/struct"
require "rom/repository/class_interface"
require "rom/repository/session"

module ROM
  # Abstract repository class to inherit from
  #
  # A repository provides access to composable relations and commands.
  # Its job is to provide application-specific data that is already materialized, so that
  # relations don't leak into your application layer.
  #
  # Typically, you're going to work with Repository::Root that is configured to
  # use a single relation as its root, and compose aggregates and use changesets and commands
  # against the root relation.
  #
  # @example
  #   rom = ROM.setup(:sql, 'sqlite::memory') do |conf|
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
    extend Dry::Core::Cache
    extend Dry::Core::ClassAttributes

    extend ClassInterface
    extend Initializer

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
    option :container, allow: ROM::Container

    # @!attribute [r] struct_namespace
    #   @return [Module,Class] The namespace for auto-generated structs
    option :struct_namespace, default: -> { self.class.struct_namespace }

    # @!attribute [r] auto_struct
    #   @return [Boolean] The container used to set up a repo
    option :auto_struct, default: -> { self.class.auto_struct }

    # @!attribute [r] relations
    #   @return [RelationRegistry] The relation proxy registry used by a repo
    attr_reader :relations

    # Initializes a new repository object
    #
    # @api private
    def initialize(*)
      super
      @relations = {}
    end
    ruby2_keywords(:initialize) if respond_to?(:ruby2_keywords, true)

    # Open a database transaction
    # @option gateway [Symbol] gateway key. For Repository::Root descendants
    #                                       it's taken from the root relation
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
    # @example with automatic savepoints
    #   user = transaction(auto_savepoint: true) do
    #     create(changeset(name: 'Jane'))
    #
    #     transaction do |t|
    #       update(changeset(name: 'John'))
    #       t.rollback!
    #     end
    #   end
    #
    #   user
    #   # => #<ROM::Struct::User id=1 name="Jane">
    #
    # @api public
    def transaction(gateway: :default, **opts, &block)
      container.gateways[gateway].transaction(**opts, &block)
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
    def session
      session = Session.new(self)
      yield(session)
      transaction { session.commit! }
    end
  end
end

require "rom/repository/root"
