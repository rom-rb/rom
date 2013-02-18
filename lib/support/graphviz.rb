module DataMapper
  module Support

    module Graphviz

      # Draw the relation graph contained in the given +env+
      #
      # @example
      #
      #   DM_ENV = DataMapper::Environment.new
      #   DM_ENV.setup(:postgres, :uri => 'postgres://localhost/test')
      #   DM_ENV.finalize
      #
      #   DataMapper::Support::Graphviz.draw_relation_graph(DM_ENV)
      #
      #   # => puts file "graph.png" into the current working directory
      #
      # @param [Environment] env
      #   the environment containing the graph
      #
      # @param [String] file_name
      #   the name of the (png) image file to create
      #
      # @return [undefined]
      #
      # @api public
      def self.draw_relation_graph(env, file_name = 'graph.png')
        require 'graphviz'

        # Create a new graph
        g = GraphViz.new( :G, :type => :digraph )

        relations = env.relations

        map = {}

        relations.nodes.each do |relation_node|
          node = g.add_nodes(relation_node.name.to_s)
          map[relation_node] = node
        end

        relations.edges.each do |edge|
          source = map[edge.source_node]
          target = map[edge.target_node]

          g.add_edges(source, target, :label => edge.name.to_s)
        end

        relations.connectors.each do |name, connector|
          source = map[connector.source_node]
          target = map[connector.node]

          relationship = connector.relationship

          label = "#{relationship.source_model.name}##{relationship.name} [#{name}]"

          g.add_edges(source, target, :label => label, :style => 'bold', :color => 'blue')
        end

        # Generate output image
        g.output( :png => file_name )
      end

    end # module Graphviz
  end # module Support
end # module DataMapper
