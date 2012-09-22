module DataMapper
  class Mapper
    class Builder
      class Relationship

        module CollectionBehavior

          def target_model_attribute_options
            super.merge(:collection => true)
          end
        end # module CollectionBehavior
      end # class Relationship
    end # class Builder
  end # class Mapper
end # module DataMapper
