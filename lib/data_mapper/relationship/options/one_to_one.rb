module DataMapper
  class Relationship
    class Options

      class OneToOne < self

        # TODO: add spec
        def type
          Relationship::OneToOne
        end

        # TODO: add spec
        def default_source_key
          :id
        end

        # TODO: add spec
        def default_target_key
          foreign_key_name(source_model.name)
        end

        # TODO: add spec
        def validator_class
          Validator::OneToOne
        end
      end # class OneToOne
    end # class Options
  end # class Relationship
end # module DataMapper
