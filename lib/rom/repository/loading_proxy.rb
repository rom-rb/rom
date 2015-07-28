module ROM
  class Repository
    class LoadingProxy
      attr_reader :name

      attr_reader :relation

      attr_reader :mapper_builder

      attr_reader :mapper

      def self.new(name, relation, mapper_builder = MapperBuilder.new)
        super
      end

      def initialize(name, relation, mapper_builder)
        @name = name
        @relation = relation
        @mapper_builder = mapper_builder
        @mapper = mapper_builder[to_ast]
      end

      def columns
        relation.columns
      end

      def combine(options)
        nodes = options.map { |key, relation| relation.named(key) }
        __new__(name, relation.combine(*nodes))
      end

      def named(new_name)
        __new__(new_name, relation)
      end

      def __new__(*args)
        self.class.new(*args, mapper_builder)
      end

      def to_a
        (relation >> mapper).to_a
      end

      def to_ast
        if relation.is_a?(Relation::Graph)
          [:graph, left.to_ast, nodes.map(&:to_ast)]
        else
          [:relation, name, columns]
        end
      end

      def respond_to_missing?(name, include_private = false)
        relation.respond_to?(name) || super
      end

      private

      def method_missing(meth, *args)
        if relation.respond_to?(meth)
          result = relation.__send__(meth, *args)

          if result.is_a?(Relation::Lazy) || result.is_a?(Relation::Graph)
            __new__(name, result)
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
