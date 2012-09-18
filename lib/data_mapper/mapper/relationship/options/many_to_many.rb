module DataMapper
  class Mapper
    class Relationship
      class Options

        class ManyToMany < self

          def type
            Relationship::ManyToMany
          end
        end # class ManyToMany
      end # class Options
    end # class Relationship
  end # class Mapper
end # module DataMapper
