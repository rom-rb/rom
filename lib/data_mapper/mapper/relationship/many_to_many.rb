module DataMapper
  class Mapper

    # Attribute
    #
    # @api private
    class Relationship

      class ManyToMany < OneToMany

        attr_reader :via
        attr_reader :join_relation

        def finalize_relation
          through        = options.through
          @via           = @mapper_class.relationships[through]
          @join_relation = DataMapper.relation_registry[through]

          super
        end

        private

        # @api private
        def relationship_builder
          Builder::ManyToMany
        end
      end # class ManyToMany

    end # class Relationship
  end # class Mapper
end # module DataMapper
