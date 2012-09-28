module DataMapper
  class RelationRegistry
    class Edge

      class Builder

        def self.build(relationship)
          return super if self < Builder

          builder =
            # TODO unify this
            if relationship.source || relationship.options[:through] ||
               (relationship.respond_to?(:via) && relationship.via)
              MultiHop
            else
              SingleHop
            end

          builder.new(relationship).build
        end

        attr_reader :relationship

        def initialize(relationship)
          @relationship = relationship
        end
      end # class Builder
    end # class Edge
  end # class RelationRegistry
end # module DataMapper
