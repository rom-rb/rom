module ROM
  class Changeset
    class Delete < Changeset
      def command
        command_compiler.(:delete, relation, mapper: false)
      end
    end
  end
end
