module ROM
  class Changeset
    class Delete < Changeset
      def command(repo)
        repo.command(:delete, relation, mapper: false)
      end
    end
  end
end
