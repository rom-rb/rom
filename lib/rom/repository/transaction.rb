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

      def commit!
        commands = ops.reduce([]) do |acc, (type, changeset)|
          acc << repo.command(type, changeset.relation).curry(changeset)
        end
        commands.map(&:call)
      end
    end
  end
end
