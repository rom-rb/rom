module DataMapper
  class Mapper
    class Builder
      class Relationship

        class ManyToOne < self
          private

          def fields
            super.merge({
              source_key => target_key,
              target_key => DataMapper::Mapper.unique_alias(target_key, name)
            })
          end
        end # class ManyToOne
      end # class Relationship
    end # class Builder
  end # class Mapper
end # module DataMapper
