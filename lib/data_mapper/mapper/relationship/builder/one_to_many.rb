module DataMapper
  class Mapper
    class Relationship
      class Builder

        class OneToMany < OneToOne
          include CollectionBehavior
        end # class OneToMany
      end # class Builder
    end # class Relationship
  end # class Mapper
end # module DataMapper
