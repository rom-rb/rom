module DataMapper
  class Relationship
    class Options

      # Options for many-to-many relationship
      #
      class ManyToMany < self

        # @see Options#type
        #
        # @return [ManyToMany]
        def type
          Relationship::ManyToMany
        end

        # @see Options#validator_class
        #
        # @return [Validator::ManyToMany]
        def validator_class
          Validator::ManyToMany
        end

      end # class ManyToMany

    end # class Options
  end # class Relationship
end # module DataMapper
