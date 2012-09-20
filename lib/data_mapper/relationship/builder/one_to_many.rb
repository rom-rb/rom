module DataMapper
  class Relationship
    class Builder

      class OneToMany < OneToOne
        include CollectionBehavior
      end # class OneToMany
    end # class Builder
  end # class Relationship
end # module DataMapper
