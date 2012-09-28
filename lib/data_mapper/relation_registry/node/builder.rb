module DataMapper
  class RelationRegistry
    class Node

      class Builder

        RELATION_SEPARATOR = '_X_'.freeze

        def self.build(edge)
          new(edge).build
        end

        def initialize(edge)
          @a = edge.a
          @b = edge.b

          join_aliases_a = join_attribute_aliases(@a.join_attributes)
          join_aliases_b = join_attribute_aliases(@b.join_attributes)

          @join_aliases = join_aliases_a.merge(join_aliases_b)
        end

        def build
          Node.new(relation, name)
        end

        private

        def name
          [@a.node.name.to_s, @b.node.name.to_s].sort.join(RELATION_SEPARATOR)
        end

        def relation
          @a.relation.rename(aliases(@a)).join(@b.relation.rename(aliases(@b)))
        end

        def aliases(edge_side)
          node            = edge_side.node
          relation        = edge_side.relation
          join_attributes = edge_side.join_attributes

          header_names(relation).each_with_object({}) { |name, aliases|
            aliases[name.to_sym] = attribute_alias(node, join_attributes, name)
          }
        end

        def attribute_alias(node, join_attributes, name)
          if join_attributes.include?(name)
            @join_aliases[name]
          else
            unique_attribute_alias(node, name)
          end
        end

        def unique_attribute_alias(node, name)
          "#{node.name}__#{name}".to_sym
        end

        def join_attribute_aliases(join_attributes)
          id = 0
          join_attributes.each_with_object({}) { |attribute_name, aliases|
            aliases[attribute_name.to_sym] = join_attribute_alias(id += 1)
          }
        end

        def join_attribute_alias(id)
          "#{name}__join_#{id}".to_sym
        end

        def header_names(relation)
          relation.header.map(&:name)
        end
      end # class Builder
    end # class Node
  end # class RelationRegistry
end # module DataMapper
