# frozen_string_literal: true

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
    #   user_repo.update(user.id, name: "Jane Doe")
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
      def initialize(*)
        super
        @root = set_relation(self.class.root)
      end
      ruby2_keywords(:initialize) if respond_to?(:ruby2_keywords, true)
    end
  end
end
