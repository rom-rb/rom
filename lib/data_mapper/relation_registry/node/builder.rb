module DataMapper
  class RelationRegistry
    class Node

      class Builder

        @counter = 0

        def self.counter
          @counter += 1
        end

        def self.build(edge)
          new(edge).node
        end

        attr_reader :node

        def initialize(edge)
          a  = edge.a
          b  = edge.b
          op = edge.op

          aliasing  = Aliasing.new(edge, self.class.counter)
          aliased_a = a.relation.rename(aliasing.a)
          aliased_b = b.relation.rename(aliasing.b)

          relation = aliased_a.join(aliased_b)

          if op
            relation = relation.instance_eval(&op).optimize
          end

          @node = Node::Relation.new(relation, aliasing)
        end
      end # class Builder
    end # class Node
  end # class RelationRegistry
end # module DataMapper
