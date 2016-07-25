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
      extend ClassMacros

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
      def initialize(container)
        super
        @root = __send__(self.class.root)
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
      # @overload aggregate(options)
      #   Composes an aggregate by delegating to combine_children method.
      #
      #   @param options [Hash] An option hash
      #
      #   @see RelationProxy::Combine#combine_children
      #
      # @return [RelationProxy]
      #
      # @api public
      def aggregate(*args)
        if args[0].is_a?(Hash) && args.size == 1
          root.combine_children(args[0])
        else
          root.combine(*args)
        end
      end

      # @overload changeset(name, *args)
      #   Delegate to Repository#changeset
      #   @see Repository#changeset
      #
      # @overload changeset(data)
      #   Builds a create changeset for the root relation
      #   @example
      #     user_repo.changeset(name: "Jane")
      #   @param data [Hash] New data
      #   @return [Changeset::Create]
      #
      # @overload changeset(restriction_arg, data)
      #   Builds an update changeset for the root relation
      #   @example
      #     user_repo.changeset(1, name: "Jane Doe")
      #   @param restriction_arg [Object] An argument for the restriction view
      #   @return [Changeset::Update]
      #
      # @override Repository#changeset
      #
      # @api public
      def changeset(*args)
        if args.first.is_a?(Symbol) && relations.key?(args.first)
          super
        else
          super(self.class.root, *args)
        end
      end
    end
  end
end
