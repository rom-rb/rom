module DataMapper
  class RelationRegistry

    # Represents a directed relation edge joining 2 relation nodes
    #
    class RelationEdge < Graph::Edge

      # Left side relation node
      #
      # @return [RelationNode]
      #
      # @api private
      attr_reader :source_node

      # Right side relation node
      #
      # @return [RelationNode]
      #
      # @api private
      attr_reader :target_node

      # The map specifying the field names to join on
      #
      # @return [JoinKeyMap]
      #
      # @api private
      attr_reader :join_key_map

      # Initializes a relation edge instance
      #
      # @param [Symbol, #to_sym] name
      #   the edge's {#name}
      #
      # @param [RelationNode] source_node
      #   the {#left} side representing the {#source_node}
      #
      # @param [RelationNode] target_node
      #   the {#right} side representing the {#target_node}
      #
      # @return [undefined]
      #
      # @api private
      def initialize(name, source_node, target_node, join_key_map)
        super(name, source_node, target_node)
        @source_node  = source_node
        @target_node  = target_node
        @join_key_map = join_key_map
      end

      # Builds a joined relation from source and target nodes
      #
      # @return [Object] instance of the engine's relation class
      #
      # @api private
      def relation(*args)
        source_node.join(target_node, *args)
      end

      # Returns source aliases
      #
      # @return [AliasSet]
      #
      # @api private
      def source_aliases
        source_node.aliases
      end

      # Returns target aliases
      #
      # @return [AliasSet]
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

    end # class RelationEdge

  end # class RelationRegistry
end # module DataMapper
