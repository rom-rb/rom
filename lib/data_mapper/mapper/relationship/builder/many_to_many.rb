module DataMapper
  class Mapper
    class Relationship
      class Builder

        class OneToMany < self

          def operation
            lambda do |targets, relationship|
              source_key = relationship.source_key
              target_key = relationship.target_key

              rename(relationship.options[:rename].merge({
                source_key => target_key
              })).join(targets)
            end
          end

          private

          def fields
            super.merge({
              source_key => target_key,
            })
          end

          def target_model_attribute_options
            super.merge(:collection => true)
          end

          def default_source_key
            :id
          end

          def default_target_key
            foreign_key_name
          end
        end
      end
    end
  end
end
