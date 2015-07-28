module ROM
  module SQL
    class Relation < ROM::Relation
      def self.inherited(klass)
        super
        klass.exposed_relations << :select << :order
      end
    end
  end

  class Relation
    def to_ast
      [:relation, name, columns]
    end

    class Lazy
      undef_method :select

      def to_ast
        relation.to_ast
      end
    end

    class Graph
      def to_ast
        [:graph, left.to_ast, nodes.map(&:to_ast)]
      end
    end
  end
end
