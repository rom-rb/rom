require 'backports'
require 'backports/basic_object' unless defined?(BasicObject)
require 'rubygems'

if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start do
    add_filter "/spec/"
    add_group "Finalizer",    "lib/data_mapper/finalizer"
    add_group "Mapper",       "lib/data_mapper/mapper"
    add_group "Relation",     "lib/data_mapper/relation"
    add_group "Relationship", "lib/data_mapper/relationship"
    add_group "Engine",       "lib/data_mapper/engine"
  end
end

if RUBY_VERSION < '1.9'
  class OpenStruct
    def id
      @table.fetch(:id) { super }
    end
  end
end

require 'pp'
require 'ostruct'
require 'dm-mapper'
require 'virtus'

require 'data_mapper/engine/veritas'
require 'data_mapper/engine/arel'
require 'data_mapper/engine/in_memory'
require 'data_mapper/engine/mongo'

require 'rspec'

%w(shared support).each do |name|
  Dir[File.expand_path("../#{name}/**/*.rb", __FILE__)].each { |file| require file }
end

RSpec.configure do |config|

  config.after(:each) do
    if example.metadata[:example_group][:file_path] =~ /unit|shared/
      DM_ENV.reset!
    end
  end

  config.include(SpecHelper)
end

include DataMapper

DM_ENV = TestEnv.new

TEST_ENGINE = TestEngine.new('db://localhost/test')

DM_ENV.engines[:test] = TEST_ENGINE
