module DataMapper
  class RelationRegistry
    class Builder

      # Builds relation nodes for relationships
      #
      class BaseBuilder < self

        # @api private
        def name
          @name ||= NodeName.new(left_name, right_name, relationship.name).to_connector_name
        end

      end # class BaseBuilder

    end # class Builder
  end # class RelationRegistry
end # module DataMapper
