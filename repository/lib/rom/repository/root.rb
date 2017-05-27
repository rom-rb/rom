require 'dry/core/class_attributes'

module ROM
  class Repository
    # A specialized repository type dedicated to work with a root relation
    #
    # This repository type builds commands and aggregates for its root relation
    #
    # @example
    #   class UserRepo < ROM::Repository[:users]
    #     commands :create, update: :by_pk, delete: :by_pk
    #   end
    #
    #   rom = ROM.container(:sql, 'sqlite::memory') do |conf|
    #     conf.default.create_table(:users) do
    #       primary_key :id
    #       column :name, String
    #     end
    #   end
    #
    #   user_repo = UserRepo.new(rom)
    #
    #   user = user_repo.create(name: "Jane")
    #
    #   changeset = user_repo.changeset(user.id, name: "Jane Doe")
    #   user_repo.update(user.id, changeset)
    #
    #   user_repo.delete(user.id)
    #
    # @api public
    class Root < Repository
      # @!method self.root
      #   Get or set repository root relation identifier
      #
      #   This method is automatically used when you define a class using
      #   MyRepo[:rel_identifier] shortcut
      #
      #   @overload root
      #     Return root relation identifier
      #     @return [Symbol]
      #
      #   @overload root(identifier)
      #     Set root relation identifier
      #     @return [Symbol]
      defines :root

      # @!attribute [r] root
      #   @return [RelationProxy] The root relation
      attr_reader :root

      # Sets descendant root relation
      #
      # @api private
      def self.inherited(klass)
        super
        klass.root(root)
      end

      # @see Repository#initialize
      def initialize(container, opts = EMPTY_HASH)
        super
        @root = relations[self.class.root]
      end

      # Compose a relation aggregate from the root relation
      #
      # @overload aggregate(*associations)
      #   Composes an aggregate from configured associations on the root relation
      #
      #   @example
      #     user_repo.aggregate(:tasks, :posts)
      #
      #   @param *associations [Array<Symbol>] A list of association names
      #
      # @overload aggregate(*associations, *assoc_opts)
      #   Composes an aggregate from configured associations and assoc opts
      #   on the root relation
      #
      #   @example
      #     user_repo.aggregate(:tasks, posts: :tags)
      #
      #   @param *associations [Array<Symbol>] A list of association names
      #   @param [Hash] Association options for nested aggregates
      #
      # @overload aggregate(options)
      #   Composes an aggregate by delegating to combine_children method.
      #
      #   @example
      #     user_repo.aggregate(tasks: :labels)
      #     user_repo.aggregate(posts: [:tags, :comments])
      #
      #   @param options [Hash] An option hash
      #
      #   @see RelationProxy::Combine#combine_children
      #
      # @return [RelationProxy]
      #
      # @api public
      def aggregate(*args)
        if args.all? { |arg| arg.is_a?(Symbol) }
          root.combine(*args)
        else
          args.reduce(root) { |a, e| a.combine(e) }
        end
      end

      # @overload changeset(name, *args)
      #   Delegate to Repository#changeset
      #
      #   @see Repository#changeset
      #
      # @overload changeset(data)
      #   Builds a create changeset for the root relation
      #
      #   @example
      #     user_repo.changeset(name: "Jane")
      #
      #   @param data [Hash] New data
      #
      #   @return [Changeset::Create]
      #
      # @overload changeset(primary_key, data)
      #   Builds an update changeset for the root relation
      #
      #   @example
      #     user_repo.changeset(1, name: "Jane Doe")
      #
      #   @param primary_key [Object] Primary key for restricting relation
      #
      #   @return [Changeset::Update]
      #
      # @overload changeset(changeset_class)
      #   Return a changeset prepared for repo's root relation
      #
      #   @example
      #     changeset = user_repo.changeset(MyChangeset)
      #
      #     changeset.relation == user_repo.root
      #     # true
      #
      #   @param [Class] changeset_class Your custom changeset class
      #
      #   @return [Changeset]
      #
      # @see Repository#changeset
      #
      # @api public
      def changeset(*args)
        if args.first.is_a?(Symbol) && relations.key?(args.first)
          super
        elsif args.first.is_a?(Class)
          klass, *rest = args
          super(klass[klass.relation || self.class.root], *rest)
        else
          super(root.name, *args)
        end
      end
    end
  end
end
