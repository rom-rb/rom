require 'pp'
require 'ostruct'
require 'yaml'
require 'backports'
require 'backports/basic_object' unless defined?(BasicObject)

require 'virtus'
require 'dm-mapper'
require 'data_mapper/support/veritas/adapter/in_memory'
require 'data_mapper/support/veritas/adapter/postgres'
require 'data_mapper/support/graphviz'

require 'rspec'
require 'support/ice_nine_config'
require 'support/test_env'
require 'support/helper'

if RUBY_VERSION < '1.9'
  class OpenStruct
    def id
      @table.fetch(:id) { super }
    end
  end
end

root  = File.expand_path('../..', __FILE__)
repos = YAML.load_file("#{root}/config/database.yml")

DM_ENV = TestEnv.coerce(repos)

%w[shared].each do |name|
  Dir[File.expand_path("../#{name}/**/*.rb", __FILE__)].each do |file|
    require file
  end
end

include(DataMapper)

RSpec.configure do |config|

  config.before(:each) do
    if example.metadata[:example_group][:file_path] =~ /integration|isolation/
      DM_ENV.finalize
    end
  end

  config.after(:each) do
    if example.metadata[:example_group][:file_path] =~ /unit|shared/
      DM_ENV.reset
    end
  end

  config.after(:all) do
    DM_ENV.reset
  end

  config.include(SpecHelper)
end
