module DataMapper
  class Mapper

    class Builder

      def self.call(edge, source_mapper_class)
        new(edge, source_mapper_class).mapper
      end

      def initialize(edge, source_mapper_class)
        @edge          = edge
        @source_model  = @edge.source_model
        @target_model  = @edge.target_model
        @source_mapper = source_mapper_class

        @name = @edge.name
      end

      def mapper
        mapper_class.new(@edge.relation)
      end

      private

      def mapper_class
        klass = Mapper::Relation.from(@source_mapper, mapper_name)

        remap_fields(klass)

        klass.map(@name, @target_model, target_model_attribute_options)

        if @edge.collection_target?
          klass.send(:include, Relationship::OneToMany::Iterator)
        end

        klass.finalize_attributes

        klass
      end

      def remap_fields(mapper)
        source_aliases.each do |field, alias_name|
          attribute = mapper.attributes.for_field(field)
          if attribute
            mapper.map(attribute.name, attribute.type, :key => attribute.key?, :to => alias_name)
          end
        end

        mapper
      end

      def source_aliases
        @edge.source_aliases
      end

      def target_aliases
        if @edge.via?
          determine_target_aliases(@edge)
        else
          @edge.target_aliases
        end
      end

      def determine_target_aliases(edge)
        via_edge = @source_mapper.relations.edges.detect { |e| e.name == edge.via }

        if via_edge.via?
          determine_target_aliases(via_edge)
        else
          via_edge.target_aliases
        end
      end

      def mapper_name
        "#{Inflector.camelize(@edge.left.name.to_s)}_X_#{Inflector.camelize(@edge.right.name.to_s)}_Mapper"
      end

      def target_model_attribute_options
        {
          :collection => @edge.collection_target?,
          :aliases    => target_aliases
        }
      end
    end # class Builder
  end # class Mapper
end # module DataMapper
