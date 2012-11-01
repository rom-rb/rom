module DataMapper
  class Relationship
    class Options

      # Options for OneToMany relationship
      #
      class OneToMany < self

        # @see Options#type
        #
        # @return [OneToMany]
        def type
          Relationship::OneToMany
        end

        # @see Options#validator_class
        #
        # @return [Validator::OneToMany]
        def validator_class
          Validator::OneToMany
        end

        # @see Options#default_source_key
        #
        def default_source_key
          :id
        end

        # @see Options#default_target_key
        #
        def default_target_key
          self.class.foreign_key_name(source_model.name)
        end

      end # class OneToMany

    end # class Options
  end # class Relationship
end # module DataMapper
