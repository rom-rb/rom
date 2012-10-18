module DataMapper
  class Mapper

    class Builder

      def self.call(connector, source_mapper_class)
        new(connector, source_mapper_class).mapper
      end

      def initialize(connector, source_mapper_class)
        @connector     = connector
        @source_model  = @connector.source_model
        @target_model  = @connector.target_model
        @source_mapper = source_mapper_class

        @name = @connector.name
      end

      def mapper
        mapper_class.new(@connector.relation)
      end

      private

      def mapper_class
        klass = Mapper::Relation.from(@source_mapper, mapper_name)

        remap_fields(klass)

        klass.map(@name, @target_model, target_model_attribute_options)

        if @connector.collection_target?
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
        if @connector.via?
          determine_source_aliases(@connector)
        else
          @connector.source_aliases
        end
      end

      def determine_source_aliases(connector)
        via_connector = @source_mapper.relations.connectors[connector.via]

        if via_connector.via?
          determine_source_aliases(via_connector)
        else
          via_connector.source_aliases
        end
      end

      def mapper_name
        "#{@source_model.name}_X_#{Inflector.camelize(@connector.name.to_s)}_Mapper"
      end

      def target_model_attribute_options
        {
          :collection => @connector.collection_target?,
          :aliases    => @connector.target_aliases
        }
      end
    end # class Builder
  end # class Mapper
end # module DataMapper
