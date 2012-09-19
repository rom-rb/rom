module DataMapper
  class Mapper
    class Relationship
      class Builder

        class OneToOne < self

          def operation
            lambda do |targets, relationship|
              source_key = relationship.source_key
              target_key = relationship.target_key

              rename(relationship.options[:renamings].merge({
                source_key => target_key
              })).join(targets)
            end
          end

          private

          def fields
            super.merge(source_key => target_key)
          end
        end # class OneToOne
      end # class Builder
    end # class Relationship
  end # class Mapper
end # module DataMapper
