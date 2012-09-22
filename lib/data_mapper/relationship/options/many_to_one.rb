module DataMapper
  class Relationship
    class Options

      class ManyToOne < self

        def type
          Relationship::ManyToOne
        end

        def default_source_key
          foreign_key_name(target_model.name)
        end

        def default_target_key
          :id
        end

        def validator_class
          Validator::ManyToOne
        end
      end # class ManyToOne
    end # class Options
  end # class Relationship
end # module DataMapper
