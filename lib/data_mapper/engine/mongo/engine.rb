module DataMapper
  class Engine
    module Mongo

      # Engine for Mongo
      #
      class Engine < DataMapper::Engine
        register_as :mongo

        attr_reader :client

        attr_reader :db

        alias_method :collections, :relations

        DEFAULT_PORT = 27017

        def initialize(uri)
          super
          establish_connection
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
          @db[name]
        end

        # @api private
        def gateway_relation(collection)
          Gateway.new(collection.name, collection)
        end

        private

        def establish_connection
          @client = ::Mongo::MongoClient.new(uri.host, uri.port || DEFAULT_PORT)
          @db     = @client[uri.path.sub(/^\//, '')]
        end

      end # class Engine

    end # module Mongo
  end # class Engine
end # module DataMapper
