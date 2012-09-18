module DataMapper
  class Mapper
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
        end # class ManyToOne
      end # class Options
    end # class Relationship
  end # class Mapper
end # module DataMapper
