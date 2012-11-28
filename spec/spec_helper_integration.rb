ROOT = File.expand_path('../..', __FILE__)

require 'backports'
require 'backports/basic_object' unless defined?(BasicObject)
require 'rubygems'

begin
  require 'rspec'  # try for RSpec 2
rescue LoadError
  require 'spec'   # try for RSpec 1
  RSpec = Spec::Runner
end

require 'veritas-do-adapter'
require 'virtus'

require 'do_postgres'
require 'do_mysql'
require 'do_sqlite3'

require 'randexp'

require 'dm-mapper'
require 'db_setup'

require 'monkey_patches'

ENV['TZ'] = 'UTC'

# require spec support files and shared behavior
Dir[File.expand_path('../**/shared/**/*.rb', __FILE__)].each { |file| require file }

module Spec

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
      g.add_edges(source, target, :label => name.to_s, :style => 'bold', :color => 'blue')
    end

    # Generate output image
    g.output( :png => file_name )
  end
end

RSpec.configure do |config|
  config.after(:all) do

    [ Mapper.descendants + Mapper::Relation.descendants ].flatten.uniq.each do |klass|
      name = klass.name

      const, parent =
        if name =~ /::/
          [ name.split('::').last, klass.model ]
        else
          [ name.to_sym, Object ]
        end

      next unless parent

      if parent.const_defined?(const)
        parent.send(:remove_const, const)
      end
    end

    DataMapper::Mapper.instance_variable_set('@descendants', [])
    DataMapper::Mapper::Relation.instance_variable_set('@descendants', [])

    DataMapper.engines.each do |name, engine|
      engine.instance_variable_set(:@relations, engine.relations.class.new(engine))
    end

    DataMapper::Mapper.instance_variable_set(:@relations, nil)

    DataMapper.mapper_registry.instance_variable_set(:@mappers, {})

    DataMapper.instance_variable_set(:@finalized, false)
  end

  config.before do
    DataMapper.finalize
  end
end
