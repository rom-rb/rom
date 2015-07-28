module ROM
  module SQL
    class Relation < ROM::Relation
      # TODO: This will go away when ROM core generates Lazy classes dedicated for each
      # relation class and by adding configuration for the query interface which
      # could be easily exposed by lazy relations for cases like repository
      def self.inherited(klass)
        super
        klass.exposed_relations << :select << :order
      end
    end
  end

  # TODO: consider moving this to rom core
  class Relation
    def to_ast
      [:relation, name, columns]
    end

    class Lazy
      # TODO: this will go away when Lazy exposes the whole query interface
      undef_method :select # Object#select bites me once again

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
