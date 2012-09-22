module DataMapper
  class Mapper
    class Builder
      class Relationship

        attr_reader :name
        attr_reader :source_mapper
        attr_reader :target_model
        attr_reader :source_key
        attr_reader :target_key
        attr_reader :aliases

        def initialize(source_mapper, options)
          @name          = options.name
          @source_mapper = source_mapper.class
          @target_model  = options.target_model
          @source_key    = options.source_key
          @target_key    = options.target_key
          @aliases       = options.aliases
        end

        def mapper_class
          klass = remap_fields(Mapper::Relation.from(source_mapper))
          klass.map(name, target_model_attribute_options)
          klass.finalize_attributes
          klass
        end

        def operation
          lambda do |targets, relationship|
            rename(relationship.source_aliases).join(targets)
          end
        end

        private

        def remap_fields(mapper)
          fields.each do |name, field|
            original = mapper.attributes[name]
            mapper.map(name, :type => original.type, :key => original.key?, :to => field)
          end

          mapper
        end

        def fields
          @aliases
        end

        def target_model_attribute_options
          { :type => target_model }
        end
      end # class Relationship
    end # class Builder
  end # class Mapper
end # module DataMapper
