module DataMapper
  class RelationRegistry
    class Builder

      # Represents a joined relation node name
      #
      class NodeName

        # Separator used to split left/right sides
        SEPARATOR = '_X_'.freeze

        # The left node used to construct the name
        #
        # @return [RelationNode]
        #
        # @api private
        attr_reader :left

        # The right node used to construct the name
        #
        # @return [RelationNode]
        #
        # @api private
        attr_reader :right

        # The (optional) relationship used to construct the name
        #
        # @return [Relationship, nil]
        #
        # @api private
        attr_reader :relationship

        # Initialize a node name
        #
        # @param [RelationNode] left
        #   the left node used to construct the name
        #
        # @param [RelationNode] right
        #   the right node used to construct the name
        #
        # @param [Relationship, nil] relationship
        #   the (optional) relationship used to construct the name
        #
        # @return [undefined]
        #
        # @api private
        def initialize(left, right, relationship = nil)
          @left         = left
          @right        = right
          @relationship = relationship

          unless @left && @right
            raise ArgumentError, "+left+ and +right+ must be defined"
          end
        end

        # Coerce the name to a string
        #
        # @return [String]
        #
        # @api private
        def to_s
          to_a.join(SEPARATOR)
        end

        # Coerce the name to a symbol
        #
        # @return [Symbol]
        #
        # @api private
        def to_sym
          to_s.to_sym
        end

        # Coerce the name to an array
        #
        # @return [Array]
        #
        # @api private
        def to_a
          [ left.to_sym, right_name ]
        end

        # Coerce the name to a connector name
        #
        # FIXME
        #
        # Refactor so that a missing relationship
        # doesn't lead to a NoMethodError. Maybe
        # the method doesn't even belong here or
        # isn't needed at all once connectors are
        # local to their source_model.
        #
        # @return [Symbol]
        #
        # @raise [NoMethodError] if no relationship is present
        #
        # @api private
        def to_connector_name
          [ left.to_sym, relationship.name ].join(SEPARATOR).to_sym
        end

        private

        # @api private
        def right_name
          relationship && relationship.operation ? relationship.name : right.to_sym
        end
      end # class NodeName
    end # class Builder
  end # class RelationRegistry
end # module DataMapper
