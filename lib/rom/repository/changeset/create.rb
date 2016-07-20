module ROM
  class Changeset
    class Create < Changeset
      def update?
        false
      end

      def create?
        true
      end
    end
  end
end
