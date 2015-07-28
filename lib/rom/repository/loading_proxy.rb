module ROM
  class Repository
    attr_reader :mapper_builder

    class LoadingProxy
      attr_reader :relation

      attr_reader :mapper_builder

      attr_reader :mapper

      def initialize(relation, mapper_builder)
        @relation = relation
        @mapper_builder = mapper_builder
        @mapper = mapper_builder[relation]
      end

      def to_a
        (relation >> mapper).to_a
      end

      def respond_to_missing?(name, include_private = false)
        relation.respond_to?(name) || super
      end

      private

      def method_missing(name, *args)
        if relation.respond_to?(name)
          result = relation.__send__(name, *args)

          if result.is_a?(Relation::Lazy) || result.is_a?(Relation::Graph)
            self.class.new(result, mapper_builder)
          else
            result
          end
        else
          super
        end
      end
    end
  end
end
