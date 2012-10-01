module DataMapper
  class RelationRegistry
    class Node

      class Builder

        def self.build(edge)
          new(edge).node
        end

        attr_reader :node

        def initialize(edge)
          a = edge.a
          b = edge.b

          aliasing  = Aliasing.new(edge)
          aliased_a = a.relation.rename(aliasing.a)
          aliased_b = b.relation.rename(aliasing.b)

          relation = aliased_a.join(aliased_b)

          @node = Node::Relation.new(relation, aliasing)
        end
      end # class Builder
    end # class Node
  end # class RelationRegistry
end # module DataMapper
