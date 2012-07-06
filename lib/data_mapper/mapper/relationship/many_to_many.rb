module DataMapper
  class Mapper

    # Attribute
    #
    # @api private
    class Relationship

      class ManyToMany < OneToMany

        def initialize(name, options)
          super
          @join_relation = DataMapper.gateway_registry[options.fetch(:through)]
        end

        def finalize_child_mapper
          @child_mapper = super.join(@join_relation)
        end

      end # class ManyToMany

    end # class Relationship
  end # class Mapper
end # module DataMapper
