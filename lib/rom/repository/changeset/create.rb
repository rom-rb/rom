module ROM
  class Changeset
    # Changeset specialization for create commands
    #
    # @api public
    class Create < Changeset
      # @!attribute [r] association
      #   @return [Array] Associated changeset or hash-like object with its association name
      option :association, reader: true, optional: true, default: proc { nil }

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
      def associate(other, assoc)
        with(association: [other, assoc])
      end

      # Prepare a command for this changeset
      #
      # @return [Command]
      #
      # @api private
      def command
        if association
          other, assoc = association

          if other.is_a?(Changeset)
            create_command.curry(self) >> other.command.with_association(assoc)
          else
            create_command.with_association(assoc).curry(self, other)
          end
        else
          create_command.curry(self)
        end
      end

      # Create a base command for this changeset
      #
      # @return [Command]
      #
      # @api private
      def create_command
        command_compiler.(command_type, relation, mapper: false, result: result)
      end

      # Return command type identifier for this changeset
      #
      # @return [Symbol]
      #
      # @api private
      def default_command_type
        :create
      end
    end
  end
end
