module DataMapper
  class Engine
    module Arel

      # Engine for Arel
      #
      class Engine < DataMapper::Engine
        attr_reader :adapter

        attr_reader :arel_engine_class

        attr_reader :arel_engines

        # @api private
        def initialize(uri, arel_engine_class = ActiveRecord::Base)
          super(Addressable::URI.parse(uri))
          @arel_engine_class = arel_engine_class
          establish_connection
          reset_engines!
        end

        # @api private
        def relation_node_class
          Node
        end

        # @api private
        def relation_edge_class
          Edge
        end

        # @api private
        def base_relation(name, header)
          ::Arel::Table.new(name, arel_engine_for(name, header))
        end

        # @api private
        def gateway_relation(relation)
          Gateway.new(relation.name, relation, relation.columns)
        end

        private

        # @api private
        def reset_engines!
          @arel_engines = {}
        end

        # @api private
        def establish_connection
          arel_engine_class.establish_connection(
            :adapter  => uri.scheme,
            :database => uri.path.sub(/^\//, ''),
            :username => uri.user,
            :password => uri.password
          )
        end

        # @api private
        def arel_engine_for(name, header)
          # TODO: this is temporary. we need to find out how to create a thin arel engine
          arel_engines.fetch(name) {
            arel_engines[name] = Class.new(arel_engine_class) { self.table_name = name }
          }
        end

      end # class Engine
    end # module Arel
  end # class Engine
end # module DataMapper
