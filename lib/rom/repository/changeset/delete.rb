module ROM
  class Changeset
    class Delete < Changeset
      # @api private
      def command
        command_compiler.(command_type, relation, mapper: false)
      end

      # @api private
      def default_command_type
        :delete
      end
    end
  end
end
