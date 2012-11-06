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

module SpecHelper

  def self.draw_relation_registry(file_name = 'graph.png')

    require 'graphviz'

    # Create a new graph
    g = GraphViz.new( :G, :type => :digraph )

    graph = DataMapper.engines[:postgres].relations

    graph.edges.each do |edge|
      left  = g.add_nodes(edge.left.name.to_s)
      right = g.add_nodes(edge.right.name.to_s)

      g.add_edges(left, right, :label => edge.name)
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
