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

require 'pp'
require 'ostruct'
require 'virtus'
require 'rspec'

require 'dm-mapper'
require 'data_mapper/support/veritas/adapter/in_memory'

require 'shared_helper'

include DataMapper

RSpec.configure do |config|

  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true

  config.after(:each) do
    if example.metadata[:example_group][:file_path] =~ /unit|shared/
      DM_ENV.reset
    end
  end

  config.include(SpecHelper)
end

DM_ENV = TestEnv.coerce(:test => 'in_memory://test')
