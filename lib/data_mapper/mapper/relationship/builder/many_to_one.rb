module DataMapper
  class Mapper
    class Relationship
      class Builder

        class ManyToOne < self
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
