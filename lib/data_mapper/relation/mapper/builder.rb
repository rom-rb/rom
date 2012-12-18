module DataMapper
  module Relation
    class Mapper < DataMapper::Mapper

      # Builds a {Mapper} from a {Graph::Connector}
      #
      # @api private
      class Builder

        # Builds a mapper based on a connector and source mapper class
        #
        # @param [Graph::Connector] connector
        #   the connector used to build the mapper
        #
        # @return [Mapper]
        #
        # @api private
        def self.call(connector)
          new(connector).mapper
        end

        # The mapper built from the instance's {Graph::Connector}
        #
        # @return [Mapper]
        #
        # @api private
        attr_reader :mapper

        # Initialize a new instance
        #
        # @param [Graph::Connector] connector
        #   the connector used to build the mapper
        #
        # @return [undefined]
        #
        # @api private
        def initialize(connector)
          @connector         = connector
          @source_mapper     = @connector.source_mapper.class
          @target_aliases    = @connector.target_aliases
          @target_model      = @connector.target_model
          @relationship_name = @connector.relationship.name
          @collection        = @connector.collection_target?

          @mapper = build
        end

        private

        def build
          klass = Relation::Mapper.from(@source_mapper, mapper_name)

          klass.map(@relationship_name, @target_model, target_mapper_options)

          if @collection
            klass.class_eval { include(Relationship::Iterator) }
          end

          klass.finalize_attributes(@connector.registry)

          klass.new(@connector.node)
        end

        def mapper_name
          "#{@source_mapper.name}_X_#{connector_name}_Mapper"
        end

        def connector_name
          Inflector.camelize(@connector.name)
        end

        def target_mapper_options
          {
            :association => true,
            :collection  => @collection,
            :aliases     => @target_aliases
          }
        end

      end # class Builder

    end # class Mapper
  end # module Relation
end # module DataMapper
