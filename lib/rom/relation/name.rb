module ROM
  class Relation
    class Name
      include Dry::Equalizer(:relation, :dataset)

      def self.[](relation, dataset = nil)
        if relation.is_a?(Name)
          relation
        else
          new(relation, dataset)
        end
      end

      attr_reader :relation

      attr_reader :dataset

      def initialize(relation, dataset = nil)
        @relation = relation
        @dataset = dataset || relation
      end

      def to_s
        if relation == dataset
          relation
        else
          "#{relation} on #{dataset}"
        end
      end

      def to_sym
        relation
      end

      def inspect
        "ROM::Relation::Name(#{to_s})"
      end

      def with(relation)
        self.class.new(relation, dataset)
      end
    end
  end
end
