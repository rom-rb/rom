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

module Veritas
  class Relation

    class Gateway < Relation
      undef_method :to_set
    end
  end
end

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
  config.before(:all) do

    # explicitly defined mappers
    User.send(:remove_const, :Mapper)                  if User.const_get('Mapper')    rescue false
    Address.send(:remove_const, :Mapper)               if Address.const_get('Mapper') rescue false

    Object.send(:remove_const, :UserMapper)            if defined?(UserMapper)
    Object.send(:remove_const, :OrderMapper)           if defined?(OrderMapper)

    Object.send(:remove_const, :InfoMapper)            if defined?(InfoMapper)
    Object.send(:remove_const, :InfoContentMapper)     if defined?(InfoContentMapper)
    Object.send(:remove_const, :TagMapper)             if defined?(TagMapper)
    Object.send(:remove_const, :SongTagMapper)         if defined?(SongTagMapper)
    Object.send(:remove_const, :SongMapper)            if defined?(SongMapper)

    # models
    Object.send(:remove_const, :User)                  if defined?(User)
    Object.send(:remove_const, :Address)               if defined?(Address)
    Object.send(:remove_const, :Song)                  if defined?(Song)
    Object.send(:remove_const, :SongTag)               if defined?(SongTag)
    Object.send(:remove_const, :Tag)                   if defined?(Tag)
    Object.send(:remove_const, :Info)                  if defined?(Info)
    Object.send(:remove_const, :InfoContent)           if defined?(InfoContent)
    Object.send(:remove_const, :Order)                 if defined?(Order)

    DataMapper::Mapper.instance_variable_set('@descendants', [])
    DataMapper::Mapper::Relation::Base.instance_variable_set('@descendants', [])
  end

  config.before do
    DataMapper.engines.each do |name, engine|
      engine.instance_variable_set(:@relations, engine.relations.class.new(engine))
    end

    DataMapper::Mapper.descendants.each do |mapper|
      mapper.instance_variable_set(:@relations, nil)
    end

    DataMapper.mapper_registry.instance_variable_set(:@mappers, {})

    DataMapper.finalize
  end
end
