require 'dry/core/class_attributes'
require 'dry/core/deprecations'

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
    #   user_repo.update(user.id, name: "Jane Doe")
    #
    #   user_repo.delete(user.id)
    #
    # @api public
    class Root < Repository
      extend Dry::Core::Deprecations::Interface

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
      #   @return [Relation] The root relation
      attr_reader :root

      # Sets descendant root relation
      #
      # @api private
      def self.inherited(klass)
        super
        klass.root(root)
      end

      # @see Repository#initialize
      def initialize(container, options = EMPTY_HASH)
        super
        @root = set_relation(self.class.root)
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
      #   Composes an aggregate by delegating to combine method.
      #
      #   @example
      #     user_repo.aggregate(tasks: :labels)
      #     user_repo.aggregate(posts: [:tags, :comments])
      #
      #   @param options [Hash] An option hash
      #
      #   @see Relation::Combine#combine_children
      #
      # @return [Relation]
      #
      # @api public
      #
      # @deprecated Use {ROM::Relation#combine} instead
      def aggregate(*args)
        root.combine(*args)
      end
      deprecate :aggregate, message: 'Use ROM::Relation#combine instead'
    end
  end
end
