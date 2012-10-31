module DataMapper
  class Relationship
    class Options

      # Options for OneToOne relationship
      #
      class OneToOne < self

        # @see Options#type
        #
        # @return [OneToOne]
        def type
          Relationship::OneToOne
        end

        # @see Options#validator_class
        #
        # @return [Validator::OneToOne]
        def validator_class
          Validator::OneToOne
        end

        # @see Options#default_source_key
        #
        def default_source_key
          :id
        end

        # @see Options#default_target_key
        #
        def default_target_key
          foreign_key_name(source_model.name)
        end

      end # class OneToOne

    end # class Options
  end # class Relationship
end # module DataMapper
