require 'pp'
require 'ostruct'
require 'yaml'

require 'dm-mapper'
require 'data_mapper/support/veritas/adapter/in_memory'
require 'data_mapper/support/veritas/adapter/postgres'
require 'data_mapper/support/veritas/adapter/sqlite3'
require 'data_mapper/support/graphviz'

require 'virtus'

require 'devtools/spec_helper'

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
DM_ADAPTER = ENV.fetch('DM_ADAPTER', :postgres).to_sym

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
