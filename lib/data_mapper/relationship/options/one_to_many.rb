module DataMapper
  class Relationship
    class Options

      class OneToMany < self

        def type
          Relationship::OneToMany
        end

        def default_source_key
          :id
        end

        def default_target_key
          foreign_key_name(source_model.name)
        end
      end # class OneToMany
    end # class Options
  end # class Relationship
end # module DataMapper
