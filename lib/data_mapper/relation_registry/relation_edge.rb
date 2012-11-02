module DataMapper
  class RelationRegistry

    # Represenets relation edge joining 2 relation nodes
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

      # Initializes a relation edge instance
      #
      # @param [Symbol, #to_sym]
      # @param [RelationNode]
      # @param [RelationNode]
      #
      # @return [undefined]
      #
      # @api private
      def initialize(name, left, right)
        super
        @source_node  = left
        @target_node  = right
      end

      # Builds a joined relation from source and target nodes
      #
      # @return [Object] instance of the engine's relation class
      #
      # @api private
      def relation
        left, right =
          if source_node.base?
            [ source_node, target_node ]
          else
            [ target_node, source_node ]
          end

        left.join(right).relation
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
