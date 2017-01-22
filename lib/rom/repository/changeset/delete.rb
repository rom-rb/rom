module ROM
  class Changeset
    # Changeset specialization for delete commands
    #
    # Delete changesets will execute delete command for its relation, which
    # means proper restricted relations should be used with this changeset.
    #
    # @api public
    class Delete < Changeset
      # Return command for this changesets
      #
      # @return [Command]
      #
      # @api private
      def command
        command_compiler.(command_type, relation, mapper: false)
      end

      # Return command type identifier for this changeset
      #
      # @return [Symbol]
      #
      # @api private
      def default_command_type
        :delete
      end
    end
  end
end
