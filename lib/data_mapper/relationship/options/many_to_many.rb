module DataMapper
  class Relationship
    class Options

      # Options for many-to-many relationship
      #
      class ManyToMany < self

        # @see [DataMapper::Relationship::Options#type]
        #
        # @return [DataMapper::Relationship::ManyToMany]
        def type
          Relationship::ManyToMany
        end

        # @see [DataMapper::Relationship::Options#validator_class]
        #
        # @return [DataMapper::Relationship::Validator::ManyToMany]
        def validator_class
          Validator::ManyToMany
        end

      end # class ManyToMany

    end # class Options
  end # class Relationship
end # module DataMapper
