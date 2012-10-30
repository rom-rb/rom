module DataMapper
  class Relationship
    class Options

      # Options for OneToMany relationship
      #
      class OneToMany < self

        # @see [DataMapper::Relationship::Options#type]
        #
        # @return [DataMapper::Relationship::OneToMany]
        def type
          Relationship::OneToMany
        end

        # @see [DataMapper::Relationship::Options#validator_class]
        #
        # @return [DataMapper::Relationship::Validator::OneToMany]
        def validator_class
          Validator::OneToMany
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

      end # class OneToMany

    end # class Options
  end # class Relationship
end # module DataMapper
