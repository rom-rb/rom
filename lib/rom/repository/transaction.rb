require 'dry/core/constants'

module ROM
  class Repository
    class Transaction
      attr_reader :repo

      attr_reader :ops

      def initialize(repo, ops = [])
        @repo = repo
        @ops = ops
      end

      def create(changeset)
        ops << [:create, changeset]
        self
      end

      def associate(changeset, assoc)
        ops << [:create, changeset, assoc]
        self
      end

      def commit!
        command = ops.map do |(type, changeset, assoc)|
          if assoc
            create_assoc_command(type, changeset, assoc)
          else
            create_command(type, changeset)
          end.curry(changeset)
        end.reduce(:>>)

        command.transaction { command.call }.value
      end

      private

      def create_command(type, changeset, opts = EMPTY_HASH)
        repo.command(type, changeset.relation, opts.merge(mapper: false))
      end

      def create_assoc_command(type, changeset, name)
        create_command(type, changeset, use: { associates: proc { associates(name) }})
      end
    end
  end
end
