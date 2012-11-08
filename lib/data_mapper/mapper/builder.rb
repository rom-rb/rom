module DataMapper
  class Mapper

    # Builds a {Mapper::Relation} from a {RelationRegistry::Connector}
    #
    # @api private
    class Builder

      # Builds a mapper based on a connector and source mapper class
      #
      # @param [RelationRegistry::Connector] connector
      #   the connector used to build the mapper
      #
      # @return [Mapper::Relation]
      #
      # @api private
      def self.call(connector)
        new(connector).mapper
      end

      # The mapper built from the instance's {RelationRegistry::Connector}
      #
      # @return [Mapper::Relation]
      #
      # @api private
      attr_reader :mapper

      # Initialize a new instance
      #
      # @param [RelationRegistry::Connector] connector
      #   the connector used to build the mapper
      #
      # @return [undefined]
      #
      # @api private
      def initialize(connector)
        @connector     = connector
        @source_model  = connector.source_model
        @target_model  = connector.target_model
        @source_mapper = connector.source_mapper.class
        @name          = connector.relationship.name

        initialize_mapper
      end

      private

      # @api private
      def initialize_mapper
        klass = Mapper::Relation.from(@source_mapper, mapper_name)

        remap_fields(klass)

        klass.map(@name, @target_model, target_model_attribute_options)

        if @connector.collection_target?
          klass.send(:include, Relationship::OneToMany::Iterator)
        end

        klass.finalize_attributes

        @mapper = klass.new(@connector.node)
      end

      # @api private
      def remap_fields(mapper)
        source_aliases.each do |field, alias_name|
          attribute = mapper.attributes.for_field(field)
          if attribute
            mapper.map(attribute.name, attribute.type, :key => attribute.key?, :to => alias_name)
          end
        end

        mapper
      end

      # @api private
      def source_aliases
        @connector.source_aliases
      end

      # @api private
      def target_aliases
        @connector.target_aliases
      end

      # @api private
      def mapper_name
        "#{@source_mapper.name}_X_#{Inflector.camelize(@connector.name)}_Mapper"
      end

      # @api private
      def target_model_attribute_options
        {
          :collection => @connector.collection_target?,
          :aliases    => target_aliases
        }
      end
    end # class Builder
  end # class Mapper
end # module DataMapper
