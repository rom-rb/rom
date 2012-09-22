module DataMapper
  class Mapper
    class Builder
      class Relationship

        class OneToOne < self
          private

          def fields
            super.merge(source_key => target_key)
          end
        end # class OneToOne
      end # class Relationship
    end # class Builder
  end # class Mapper
end # module DataMapper
