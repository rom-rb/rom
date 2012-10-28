module DataMapper
  class Relationship
    class Options

      class ManyToOne < self

        # TODO: add spec
        def type
          Relationship::ManyToOne
        end

        # TODO: add spec
        def default_source_key
          foreign_key_name(target_model.name)
        end

        # TODO: add spec
        def default_target_key
          :id
        end

        # TODO: add spec
        def validator_class
          Validator::ManyToOne
        end
      end # class ManyToOne
    end # class Options
  end # class Relationship
end # module DataMapper
