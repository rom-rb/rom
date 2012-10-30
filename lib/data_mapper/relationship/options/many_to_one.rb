module DataMapper
  class Relationship
    class Options

      class ManyToOne < self

        # @see [DataMapper::Relationship::Options#type]
        #
        # @return [DataMapper::Relationship::ManyToOne]
        def type
          Relationship::ManyToOne
        end

        # @see [DataMapper::Relationship::Options#validator_class]
        #
        # @return [DataMapper::Relationship::Validator::ManyToOne]
        def validator_class
          Validator::ManyToOne
        end

        # @see [DataMapper::Relationship::Options#default_source_key]
        #
        def default_source_key
          foreign_key_name(source_model.name)
        end

        # @see [DataMapper::Relationship::Options#target_source_key]
        #
        def default_target_key
          :id
        end

      end # class ManyToOne
    end # class Options
  end # class Relationship
end # module DataMapper
