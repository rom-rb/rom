module DataMapper
  module Relation
    class Graph

      # Represents a directed relation edge joining 2 relation nodes
      #
      class Edge

        include Equalizer.new(:name)

        # The edge name
        #
        # @example
        #
        #   left  = Node.new(:left)
        #   right = Node.new(:right)
        #   edge = Edge.new(:name, left, right)
        #   edge.name
        #
        # @return [Symbol]
        #
        # @api public
        attr_reader :name

        # Left side relation node
        #
        # @return [Node]
        #
        # @api private
        attr_reader :source_node

        # Right side relation node
        #
        # @return [Node]
        #
        # @api private
        attr_reader :target_node

        # The object specifying how to perform the join
        #
        # @return [Relationship::JoinDefinition]
        #
        # @api private
        attr_reader :join_definition

        # Initializes a relation edge instance
        #
        # @param [Symbol, #to_sym] name
        #   the edge's {#name}
        #
        # @param [Node] source_node
        #   the {#left} side representing the {#source_node}
        #
        # @param [Node] target_node
        #   the {#right} side representing the {#target_node}
        #
        # @return [undefined]
        #
        # @api private
        def initialize(name, source_node, target_node)
          @name  = name
          @nodes = Set[ source_node, target_node ]

          @source_node     = source_node
          @target_node     = target_node
          @join_definition = name.relationship.join_definition
        end

        # Builds a joined relation from source and target nodes
        #
        # @return [Object] instance of the engine's relation class
        #
        # @api private
        def node(*args)
          source_node.join(target_node, *args)
        end

        # Returns source aliases
        #
        # @return [Aliases]
        #
        # @api private
        def source_aliases
          source_node.aliases
        end

        # Returns target aliases
        #
        # @return [Aliases]
        #
        # @api private
        def target_aliases
          target_node.aliases
        end

        # Returns source node name
        #
        # @return [Symbol]
        #
        # @api private
        def source_name
          source_node.name
        end

        # Returns target node name
        #
        # @return [Symbol]
        #
        # @api private
        def target_name
          target_node.name
        end

      end # class Edge

    end # class Graph
  end # module Relation
end # module DataMapper
