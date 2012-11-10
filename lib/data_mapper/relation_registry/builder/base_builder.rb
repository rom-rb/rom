module DataMapper
  class RelationRegistry
    class Builder

      # Builds relation nodes for relationships
      #
      class BaseBuilder < self

        # The name of the built {RelationNode}
        #
        # @return [NodeName]
        #
        # @api private
        def name
          @name ||= NodeName.new(left_name, right_name, relationship)
        end

      end # class BaseBuilder

    end # class Builder
  end # class RelationRegistry
end # module DataMapper
