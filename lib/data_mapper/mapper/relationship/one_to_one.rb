module DataMapper
  class Mapper

    # Attribute
    #
    # @api private
    class Relationship

      class OneToOne < Relationship

        private

        def default_source_key
          :id
        end

        def default_target_key
          foreign_key_name
        end

        # @api private
        def relationship_builder
          Builder::OneToOne
        end
      end # class OneToOne

    end # class Relationship
  end # class Mapper
end # module DataMapper
