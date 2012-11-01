module DataMapper
  class Relationship
    class Options

      class ManyToOne < self

        # @see Options#type
        #
        # @return [ManyToOne]
        def type
          Relationship::ManyToOne
        end

        # @see Options#validator_class
        #
        # @return [Validator::ManyToOne]
        def validator_class
          Validator::ManyToOne
        end

        # @see Options#default_source_key
        #
        def default_source_key
          self.class.foreign_key_name(source_model.name)
        end

        # @see Options#default_target_key
        #
        def default_target_key
          :id
        end

      end # class ManyToOne
    end # class Options
  end # class Relationship
end # module DataMapper
