require 'pp'
require 'ostruct'
require 'yaml'

require 'rom-relation'
require 'rom/support/axiom/adapter/in_memory'
require 'rom/support/axiom/adapter/postgres'
require 'rom/support/axiom/adapter/sqlite3'
require 'rom/support/graphviz'

require 'devtools/spec_helper'
require 'bogus/rspec'

if RUBY_VERSION < '1.9'
  class OpenStruct
    def id
      @table.fetch(:id) { super }
    end
  end
end

root  = File.expand_path('../..', __FILE__)
repos = YAML.load_file("#{root}/config/database.yml")

ROM_ENV = TestEnv.coerce(repos)
ROM_ADAPTER = ENV.fetch('ROM_ADAPTER', :postgres).to_sym

include(ROM)

Bogus.configure do |config|
  config.search_modules << ROM
end

RSpec.configure do |config|
  config.mock_with Bogus::RSpecAdapter

  config.before(:each) do
    if example.metadata[:example_group][:file_path] =~ /integration|isolation/
      ROM_ENV.finalize
    end
  end

  config.after(:each) do
    if example.metadata[:example_group][:file_path] =~ /unit|shared/
      ROM_ENV.reset
    end
  end

  config.after(:all) do
    ROM_ENV.reset
  end

  config.include(SpecHelper)
end
