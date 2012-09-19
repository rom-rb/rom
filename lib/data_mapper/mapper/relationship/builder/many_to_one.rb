module DataMapper
  class Mapper
    class Relationship
      class Builder

        class ManyToOne < self

          def operation
            lambda do |targets, relationship|
              name       = relationship.name
              source_key = relationship.source_key
              target_key = relationship.target_key

              rename(relationship.options[:renamings].merge({
                source_key => target_key,
                target_key => unique_alias(target_key, name)
              })).join(targets)
            end
          end

          private

          def fields
            super.merge({
              source_key => target_key,
              target_key => source_mapper.unique_alias(target_key, name)
            })
          end
        end # class ManyToOne
      end # class Builder
    end # class Relationship
  end # class Mapper
end # module DataMapper
