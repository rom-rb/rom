require 'rom/relation/graph'
require 'rom/relation/commands'

module ROM
  class Relation
    # Represents a relation graphs which combines root relation
    # with other relation nodes
    #
    # @api public
    class Combined < Graph
      include Commands

      # Create a new relation combined with others
      #
      # @param [Relation] root
      # @param [Array<Relation>] nodes
      #
      # @return [Combined]
      #
      # @api public
      def self.new(root, nodes)
        root_ns = root.options[:struct_namespace]
        super(root, nodes.map { |node| node.struct_namespace(root_ns) })
      end

      # Combine this graph with more nodes
      #
      # @param [Array<Relation::Lazy>]
      #
      # @return [Graph]
      #
      # @api public
      def combine_with(*others)
        self.class.new(root, nodes + others)
      end

      # @api public
      # @see Relation#combine
      def combine(*args)
        self.class.new(root, nodes + root.combine(*args).nodes)
      end

      # Materialize combined relation
      #
      # @return [Loaded]
      #
      # @api public
      def call(*args)
        left = root.with(auto_struct: false).call(*args)

        right =
          if left.empty?
            nodes.map { |node| Loaded.new(node, EMPTY_ARRAY) }
          else
            nodes.map { |node| node.call(left) }
          end

        if auto_map?
          Loaded.new(self, mapper.([left, right]))
        else
          Loaded.new(self, [left, right])
        end
      end

      # Return a new combined relation with adjusted node returned from a block
      #
      # @example with a node identifier
      #   aggregate(:tasks).node(:tasks) { |tasks| tasks.prioritized }
      #
      # @example with a nested path
      #   aggregate(tasks: :tags).node(tasks: :tags) { |tags| tags.where(name: 'red') }
      #
      # @param [Symbol] name The node relation name
      #
      # @yieldparam [RelationProxy] The relation node
      # @yieldreturn [RelationProxy] The new relation node
      #
      # @return [RelationProxy]
      #
      # @api public
      def node(name, &block)
        if name.is_a?(Symbol) && !nodes.map { |n| n.name.key }.include?(name)
          raise ArgumentError, "#{name.inspect} is not a valid aggregate node name"
        end

        new_nodes = nodes.map { |node|
          case name
          when Symbol
            name == node.name.key ? yield(node) : node
          when Hash
            other, *rest = name.flatten(1)
            if other == node.name.key
              nodes.detect { |n| n.name.key == other }.node(*rest, &block)
            else
              node
            end
          else
            node
          end
        }

        with_nodes(new_nodes)
      end

      # @api public
      def to_ast
        [:relation, [name.to_sym, attr_ast + node_ast, meta_ast]]
      end

      # @api private
      def node_ast
        nodes.map(&:to_ast)
      end
    end
  end
end
