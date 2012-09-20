module DataMapper
  class Relationship
    class Builder

      class ManyToOne < self
        private

        def fields
          super.merge({
            source_key => target_key,
            target_key => DataMapper::Mapper.unique_alias(target_key, name)
          })
        end
      end # class ManyToOne
    end # class Builder
  end # class Relationship
end # module DataMapper
