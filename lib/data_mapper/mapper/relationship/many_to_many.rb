module DataMapper
  class Mapper

    # Attribute
    #
    # @api private
    class Relationship

      class ManyToMany < OneToMany

        def initialize(options)
          super
          @join_relation = DataMapper.relation_registry[options.through]
        end

        def finalize_child_mapper
          @child_mapper = super.join(@join_relation)
        end

        private

        def default_source_key
          :id
        end

        def default_target_key
          foreign_key_name
        end

        # @api private
        def relationship_builder
          Builder::ManyToMany
        end
      end # class ManyToMany

    end # class Relationship
  end # class Mapper
end # module DataMapper
