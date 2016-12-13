require 'dry/core/constants'

module ROM
  class Repository
    class Session
      attr_reader :repo

      attr_reader :ops

      def initialize(repo, ops = Hash.new { |h, k| h[k] = [] })
        @repo = repo
        @ops = ops
      end

      def create(changeset)
        ops[:create] << changeset
        self
      end

      def update(changeset)
        ops[:update] << changeset
        self
      end

      def delete(relation)
        ops[:delete] << relation
        self
      end

      def associate(changeset, assoc)
        ops[:create] << [changeset, assoc]
        self
      end

      def commit!
        delete_commands = map_commands(:delete)
        update_commands = reduce_commands(:update)
        create_commands = reduce_commands(:create)

        repo.container.gateways[:default].connection.transaction do
          delete_commands.each(&:call)
          update_commands.call if update_commands
          create_commands.call if create_commands
        end
      end

      private

      def create_command(type, relation, opts = EMPTY_HASH)
        repo.command(type, relation, opts.merge(mapper: false))
      end

      def create_assoc_command(type, relation, name)
        create_command(type, relation, use: { associates: proc { associates(name) }})
      end

      def map_commands(type)
        ops[type].map { |relation| create_command(type, relation).new(relation) }
      end

      def reduce_commands(type)
        ops[type].map do |(changeset, assoc)|
          if assoc
            create_assoc_command(type, changeset.relation, assoc)
          else
            create_command(type, changeset.relation)
          end.curry(changeset)
        end.reduce(:>>)
      end
    end
  end
end
