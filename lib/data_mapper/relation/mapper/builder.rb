module DataMapper
  module Relation
    class Mapper < DataMapper::Mapper

      # Builds a {Relation::Mapper} from a {Relation::Graph::Connector}
      #
      # @api private
      class Builder

        # Builds a mapper based on a connector and source mapper class
        #
        # @param [Relation::Graph::Connector] connector
        #   the connector used to build the mapper
        #
        # @return [Relation::Mapper]
        #
        # @api private
        def self.call(connector)
          new(connector).mapper
        end

        # The mapper built from the instance's {Relation::Graph::Connector}
        #
        # @return [Relation::Mapper]
        #
        # @api private
        attr_reader :mapper

        # Initialize a new instance
        #
        # @param [Relation::Graph::Connector] connector
        #   the connector used to build the mapper
        #
        # @return [undefined]
        #
        # @api private
        def initialize(connector)
          @connector     = connector
          @aliases       = @connector.target_aliases
          @source_model  = @connector.source_model
          @target_model  = @connector.target_model
          @source_mapper = @connector.source_mapper.class
          @target_mapper = @connector.target_mapper.class
          @name          = @connector.relationship.name
          @collection    = @connector.collection_target?

          @mapper = build
        end

        private

        # @api private
        def build
          klass = Relation::Mapper.from(@source_mapper, mapper_name)

          klass.map(@name, @target_model, target_mapper_options)

          if @collection
            klass.class_eval { include(Relationship::Iterator) }
          end

          klass.finalize_attributes(@connector.registry)

          klass.new(@connector.node)
        end

        # @api private
        def mapper_name
          "#{@source_mapper.name}_X_#{Inflector.camelize(@connector.name)}_Mapper"
        end

        def target_mapper_options
          {
            :association => true,
            :collection  => @collection,
            :aliases     => @aliases
          }
        end

      end # class Builder

    end # class Mapper
  end # module Relation
end # module DataMapper
