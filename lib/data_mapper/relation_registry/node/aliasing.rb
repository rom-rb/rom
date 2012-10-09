module DataMapper
  class RelationRegistry
    class Node

      class Aliasing

        attr_reader :a
        attr_reader :b
        attr_reader :join_aliases
        attr_reader :node_name

        def initialize(edge, id)
          a  = edge.a
          b  = edge.b

          name_a = a.node.name.to_s
          name_b = b.node.name.to_s

          @node_name = "node_#{id}".to_sym

          join_aliases_a = join_attribute_aliases(a.join_attributes)
          join_aliases_b = join_attribute_aliases(b.join_attributes)

          @join_aliases = join_aliases_a.merge(join_aliases_b)

          @a = aliases(a)
          @b = aliases(b)
        end

        def each
          return to_enum unless block_given?
          @a.merge(@b).each { |name, field| yield(name, field) }
          self
        end

        def aliases(edge_side)
          node            = edge_side.node
          relation        = edge_side.relation
          join_attributes = edge_side.join_attributes

          header_names(relation).each_with_object({}) { |name, aliases|
            aliases[name.to_sym] = attribute_alias(node, join_attributes, name)
          }
        end

        def aliased(attribute_names)
          Array(attribute_names).map { |name|
            a.fetch(name) { b.fetch(name) { "#{@node_name}__#{name}" }}
          }
        end

        private

        def attribute_alias(node, join_attributes, name)
          if join_attributes.include?(name)
            @join_aliases[name]
          else
            unique_attribute_alias(node, name)
          end
        end

        def unique_attribute_alias(node, name)
          if node.base_relation?
            "#{node.name}__#{name}".to_sym
          else
            name.to_sym
          end
        end

        def join_attribute_aliases(join_attributes)
          id = 0
          join_attributes.each_with_object({}) { |attribute_name, aliases|
            aliases[attribute_name.to_sym] = join_attribute_alias(id += 1)
          }
        end

        def join_attribute_alias(id)
          "#{@node_name}__join_#{id}".to_sym
        end

        def header_names(relation)
          relation.header.map(&:name)
        end
      end # class Aliasing
    end # class Node
  end # class RelationRegistry
end # module DataMapper
