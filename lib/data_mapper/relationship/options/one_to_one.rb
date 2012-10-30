module DataMapper
  class Relationship
    class Options

      # Options for OneToOne relationship
      #
      class OneToOne < self

        # @see [DataMapper::Relationship::Options#type]
        #
        # @return [DataMapper::Relationship::OneToOne]
        def type
          Relationship::OneToOne
        end

        # @see [DataMapper::Relationship::Options#validator_class]
        #
        # @return [DataMapper::Relationship::Validator::OneToOne]
        def validator_class
          Validator::OneToOne
        end

        # @see [DataMapper::Relationship::Options#default_source_key]
        #
        def default_source_key
          :id
        end

        # @see [DataMapper::Relationship::Options#target_source_key]
        #
        def default_target_key
          foreign_key_name(source_model.name)
        end

      end # class OneToOne

    end # class Options
  end # class Relationship
end # module DataMapper
