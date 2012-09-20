module DataMapper
  class Mapper
    class Relationship
      class Builder

        class ManyToMany < OneToMany

          def initialize(source_mapper, options)
            super
            @via = @source_mapper.relationships[options.through]
          end

          def operation
            lambda do |targets, relationship|
              rename(relationship.source_aliases).
                join(relationship.join_relation.rename(relationship.join_aliases)).
                join(targets)
            end
          end

          private

          def fields
            aliases.merge(@via.source_key => @via.target_key)
          end
        end # class ManyToMany
      end # class Builder
    end # class Relationship
  end # class Mapper
end # module DataMapper
