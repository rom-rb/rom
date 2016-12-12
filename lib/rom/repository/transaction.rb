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
        new(ops.dup << [:create, changeset])
      end

      def associate(changeset, assoc)
        new(ops.dup << [:create, changeset, assoc])
      end

      def new(new_ops = [])
        self.class.new(repo, new_ops)
      end

      def commit!
        commands = ops.reduce([]) do |acc, (type, changeset, assoc)|
          command =
            if assoc
              repo.command(type, changeset.relation, mapper: false, use: {
                             associates: proc { associates(assoc) }
                           })
            else
              repo.command(type, changeset.relation)
            end.curry(changeset)
          acc << command
        end
        commands.reduce(:>>).call
      end
    end
  end
end
