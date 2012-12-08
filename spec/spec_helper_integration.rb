ROOT = File.expand_path('../..', __FILE__)

require 'backports'
require 'backports/basic_object' unless defined?(BasicObject)
require 'rubygems'

require 'rspec'

require 'veritas-do-adapter'
require 'virtus'

require 'do_postgres'
require 'do_mysql'
require 'do_sqlite3'

require 'randexp'

require 'dm-mapper'
require 'data_mapper/engine/veritas'
require 'data_mapper/engine/arel'

require 'db_setup'

ENV['TZ'] = 'UTC'

# require spec support files and shared behavior
Dir[File.expand_path('../**/shared/**/*.rb', __FILE__)].each { |file| require file }

module SpecHelper

  def self.draw_relation_registry(file_name = 'graph.png')

    require 'graphviz'

    # Create a new graph
    g = GraphViz.new( :G, :type => :digraph )

    relation_registry = DataMapper.engines[:postgres].relations

    map = {}

    relation_registry.nodes.each do |relation_node|
      node = g.add_nodes(relation_node.name.to_s)
      map[relation_node] = node
    end

    relation_registry.edges.each do |edge|
      source = map[edge.left]
      target = map[edge.right]

      g.add_edges(source, target, :label => edge.name.to_s)
    end

    relation_registry.connectors.each do |name, connector|
      source = map[connector.source_node]
      target = map[connector.node]

      relationship = connector.relationship

      label = "#{relationship.source_model}##{relationship.name} [#{name}]"

      g.add_edges(source, target, :label => label, :style => 'bold', :color => 'blue')
    end

    # Generate output image
    g.output( :png => file_name )
  end
end

RSpec.configure do |config|
  config.before(:all) do
    @test_env = TestEnv.instance
  end

  config.after(:all) do
    @test_env.clear_mappers!
  end

  config.before do
    DataMapper.finalize
  end
end
