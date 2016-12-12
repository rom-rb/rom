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

      def associate(changeset, assoc = source.name)
        ops << [:create, changeset, assoc]
        self
      end

      def commit!
        commands = ops.reduce([]) do |acc, (type, changeset, assoc)|
          command =
            if assoc
              repo.command(type, changeset.relation, use: {
                             associates: proc { associates(assoc) }
                           })
            else
              repo.command(type, changeset.relation)
            end.curry(changeset)
          acc << command
        end
        commands.reduce(:>>).call
      end

      private

      def source
        ops[0][1].relation
      end
    end
  end
end
