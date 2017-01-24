require 'rom/initializer'

module ROM
  class Changeset
    # Associated changesets automatically set up FKs
    #
    # @api public
    class Associated
      extend Initializer

      # @!attribute [r] left
      #   @return [Changeset::Create] Child changeset
      param :left

      # @!attribute [r] right
      #   @return [Changeset::Create, Hash, #to_hash] Parent changeset or data
      param :right

      # @!attribute [r] association
      #   @return [Symbol] Association identifier from relation schema
      option :association, reader: true

      # Commit changeset's composite command
      #
      # @example
      #   task_changeset = task_repo.
      #     changeset(title: 'Task One').
      #     associate(user, :user).
      #     commit
      #   # {:id => 1, :user_id => 1, title: 'Task One'}
      #
      # @return [Array<Hash>, Hash]
      #
      # @api public
      def commit
        command.call
      end

      # Create a composed command
      #
      # @example using existing parent data
      #   user_changeset = user_repo.changeset(name: 'Jane')
      #   task_changeset = task_repo.changeset(title: 'Task One')
      #
      #   user = user_repo.create(user_changeset)
      #   task = task_repo.create(task_changeset.associate(user, :user))
      #
      # @example saving both parent and child in one go
      #   user_changeset = user_repo.changeset(name: 'Jane')
      #   task_changeset = task_repo.changeset(title: 'Task One')
      #
      #   task = task_repo.create(task_changeset.associate(user, :user))
      #
      # This works *only* with parent => child(ren) changeset hierarchy
      #
      # @return [ROM::Command::Composite]
      #
      # @api public
      def command
        case right
        when Changeset, Associated
          left.command >> right.command.with_association(association)
        else
          left.create_command.with_association(association).curry(left, right)
        end
      end

      # @api private
      def relation
        left.relation
      end
    end
  end
end
