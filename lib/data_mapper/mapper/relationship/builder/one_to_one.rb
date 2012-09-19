module DataMapper
  class Mapper
    class Relationship
      class Builder

        class OneToOne < self
          private

          def fields
            super.merge(source_key => target_key)
          end
        end # class OneToOne
      end # class Builder
    end # class Relationship
  end # class Mapper
end # module DataMapper
