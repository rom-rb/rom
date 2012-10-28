module DataMapper
  class Relationship
    class Options

      class ManyToMany < self

        # TODO: add spec
        def type
          Relationship::ManyToMany
        end

        # TODO: add spec
        def validator_class
          Validator::ManyToMany
        end
      end # class ManyToMany
    end # class Options
  end # class Relationship
end # module DataMapper
