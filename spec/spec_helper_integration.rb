ROOT = File.expand_path('../..', __FILE__)

require 'backports'
require 'backports/basic_object'
require 'rubygems'

begin
  require 'rspec'  # try for RSpec 2
rescue LoadError
  require 'spec'   # try for RSpec 1
  RSpec = Spec::Runner
end

require 'veritas'
require 'veritas/optimizer'
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

module SpecHelper

  def self.print_relation_registry(print_sql = true)
    puts
    DataMapper::Mapper.relation_registry.nodes.each do |node|
      puts '+'*80
      puts "SOURCE: #{node.name}:"
      puts '-'*80
      count = 0
      edges = node.connectors.map do |name, connector|

        connector_name = connector.node.name.inspect
        header         = connector.relation.header.map(&:name).inspect

        puts
        puts "EDGE (#{count += 1})"
        puts "--------"
        puts "name:   #{connector_name}"
        puts "header: #{header}"

        if print_sql
          uri        = DataMapper.adapters[:postgres].instance_variable_get(:@uri)
          connection = DataObjects::Connection.new(uri)
          relation   = connector.relation.send(:relation)
          statement  = Veritas::Adapter::DataObjects::Statement.new(connection, relation)
          sql        = statement.to_s

          puts sql
        end
      end
      puts '+'*80
    end
  end
end # module SpecHelper

ENV['TZ'] = 'UTC'

# require spec support files and shared behavior
Dir[File.expand_path('../**/shared/**/*.rb', __FILE__)].each { |file| require file }

RSpec.configure do |config|
  config.before(:all) do
    User.send(:remove_const, :Mapper)               if defined?(User::Mapper)
    User.send(:remove_const, :UserAddressMapper)    if defined?(User::UserAddressMapper)
    Address.send(:remove_const, :Mapper)            if defined?(Address::Mapper)
    Address.send(:remove_const, :AddressUserMapper) if defined?(Address::AddressUserMapper)
    Object.send(:remove_const, :User)               if defined?(User)
    Object.send(:remove_const, :Address)            if defined?(Address)
    Object.send(:remove_const, :Song)               if defined?(Song)
    Object.send(:remove_const, :Tag)                if defined?(Tag)
    Object.send(:remove_const, :TagMapper)          if defined?(TagMapper)
    Object.send(:remove_const, :SongTagMapper)      if defined?(SongTagMapper)
    Object.send(:remove_const, :SongMapper)         if defined?(SongMapper)
    Object.send(:remove_const, :Order)              if defined?(Order)
    Object.send(:remove_const, :OrderMapper)        if defined?(OrderMapper)
    Object.send(:remove_const, :UserMapper)         if defined?(UserMapper)
    DataMapper::Mapper.instance_variable_set('@descendants', [])
    DataMapper::Mapper::Relation::Base.instance_variable_set('@descendants', [])
  end

  config.before do
    DataMapper.finalize
  end
end
