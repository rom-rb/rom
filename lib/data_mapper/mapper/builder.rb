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
        @aliases       = @connector.source_aliases
        @source_model  = @connector.source_model
        @target_model  = @connector.target_model
        @source_mapper = @connector.source_mapper.class
        @target_mapper = @connector.target_mapper.class
        @name          = @connector.relationship.name

        @source_aliases = aliases(@source_mapper)
        @target_aliases = aliases(@target_mapper)

        @collection_target = @connector.collection_target?

        @mapper = build
      end

      private

      # @api private
      def build
        klass = Mapper::Relation.from(@source_mapper, mapper_name)

        klass.map(@name, @target_model, target_model_attribute_options)

        if @collection_target
          klass.class_eval { include(Relationship::Iterator) }
        end

        attributes = klass.attributes.remap(@source_aliases).finalize

        klass.new(@connector.node, attributes)
      end

      # @api private
      def mapper_name
        "#{@source_mapper.name}_X_#{Inflector.camelize(@connector.name)}_Mapper"
      end

      # @api private
      def target_model_attribute_options
        {
          :collection => @collection_target,
          :aliases    => @target_aliases
        }
      end

      def aliases(mapper)
        prefix  = mapper.relation_name
        mapper.attributes.primitives.each_with_object({}) do |attribute, aliases|
          aliases[attribute.field] = @aliases.alias(attribute.aliased_field(prefix)).to_sym
        end
      end
    end # class Builder
  end # class Mapper
end # module DataMapper
