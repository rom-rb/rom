module ROM
  class Repository
    class Changeset
      attr_reader :relation

      attr_reader :data

      def initialize(relation, data)
        @relation = relation
        @data = data
      end

      def to_h
        data
      end
      alias_method :to_hash, :to_h
    end
  end
end
