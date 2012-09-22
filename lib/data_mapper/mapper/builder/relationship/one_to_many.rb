module DataMapper
  class Mapper
    class Builder
      class Relationship

        class OneToMany < OneToOne
          include CollectionBehavior
        end # class OneToMany
      end # class Relationship
    end # class Builder
  end # class Mapper
end # module DataMapper
