module ROM
  class Changeset
    # Changeset specialization for create commands
    #
    # @api public
    class Create < Stateful
      command_type :create

      # Associate a changeset with another changeset or hash-like object
      #
      # @example with another changeset
      #   new_user = user_repo.changeset(name: 'Jane')
      #   new_task = user_repo.changeset(:tasks, title: 'A task')
      #
      #   new_task.associate(new_user, :users)
      #
      # @example with a hash-like object
      #   user = user_repo.users.by_pk(1).one
      #   new_task = user_repo.changeset(:tasks, title: 'A task')
      #
      #   new_task.associate(user, :users)
      #
      # @param [#to_hash, Changeset] other Other changeset or hash-like object
      # @param [Symbol] assoc The association identifier from schema
      #
      # @api public
      def associate(other, name)
        Associated.new(self, other, association: name)
      end

      # Prepare a command for this changeset
      #
      # @return [Command]
      #
      # @api private
      def command
        create_command.curry(self)
      end

      # Create a base command for this changeset without curried data
      #
      # @return [Command]
      #
      # @api private
      def create_command
        command_compiler.(command_type, relation_identifier, DEFAULT_COMMAND_OPTS.merge(result: result))
      end
    end
  end
end
