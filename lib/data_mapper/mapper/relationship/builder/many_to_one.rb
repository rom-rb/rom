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

              rename(relationship.options[:rename].merge({
                source_key => target_key,
                target_key => unique_alias(name, target_key)
              })).join(targets)
            end
          end

          private

          def fields
            super.merge({
              source_key => target_key,
              target_key => source_mapper.unique_alias(name, target_key)
            })
          end

          def default_source_key
            foreign_key_name
          end

          def default_target_key
            :id
          end
        end
      end
    end
  end
end
