module DataMapper
  class Relationship
    class Options

      class OneToOne < self

        def type
          Relationship::OneToOne
        end

        def default_source_key
          :id
        end

        def default_target_key
          foreign_key_name(source_model.name)
        end
      end # class OneToOne
    end # class Options
  end # class Relationship
end # module DataMapper
