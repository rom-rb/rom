module DataMapper
  module Support

    # Support drawing the environment as a graph of relations
    #
    class Graphviz

      # TODO find out why we need flat adamantium
      #
      include Adamantium::Flat

      # Draw the relation graph contained in the given +env+
      #
      # @example
      #
      #   config = { :default => 'postgres://localhost/test' }
      #   dm_env = DataMapper::Environment.coerce(config)
      #   dm_env.finalize
      #
      #   DataMapper::Support::Graphviz.draw(dm_env)
      #
      #   # => puts file "graph.png" into the current working directory
      #
      # @param [Environment] environment
      #   the environment containing the graph
      #
      # @param [String, nil] file_name
      #   the name of the (png) image file to create
      #
      # @return [undefined]
      #
      # @api public
      def self.draw(environment, file_name = 'graph.png')
        require 'graphviz'
        new(environment.relations, file_name).draw
      end

      # Initialize a new instance
      #
      # @param [Environment] environment
      #   the environment containing the graph
      #
      # @param [String, nil] file_name
      #   the name of the (png) image file to create
      #
      # @return [undefined]
      #
      # @api private
      def initialize(relations, file_name)
        @nodes      = relations.nodes
        @edges      = relations.edges
        @connectors = relations.connectors
        @file_name  = file_name
        @node_map   = {}
        @graph      = GraphViz.new( :G, :type => :digraph )
      end

      # Draw the graph into a png file
      #
      # @api private
      def draw
        build
        graph.output( :png => file_name )
      end

      private

      attr_reader :nodes
      attr_reader :edges
      attr_reader :connectors
      attr_reader :file_name
      attr_reader :graph
      attr_reader :node_map

      def build
        add_nodes
        add_edges
        add_connectors
      end

      def add_nodes
        nodes.each do |relation_node|
          node = graph.add_nodes(relation_node.name.to_s)
          node_map[relation_node] = node
        end
      end

      def add_edges
        edges.each do |edge|
          options = self.class.edge_options(edge)
          g_nodes = g_nodes(edge.source_node, edge.target_node, options)
          graph.add_edges(*g_nodes)
        end
      end

      def add_connectors
        connectors.each do |name, connector|
          options = self.class.connector_options(name, connector.relationship)
          g_nodes = g_nodes(connector.source_node, connector.node, options)
          graph.add_edges(*g_nodes)
        end
      end

      def g_nodes(source, target, options)
        [ node_map[source], node_map[target], options ]
      end

      def self.edge_options(edge)
        { :label => edge.name.to_s }
      end

      def self.connector_options(name, relationship)
        {
          :label => label(name, relationship),
          :style => 'bold',
          :color => 'blue'
        }
      end

      def self.label(name, relationship)
        "#{relationship.source_model.name}##{relationship.name} [#{name}]"
      end
    end # module Graphviz
  end # module Support
end # module DataMapper
