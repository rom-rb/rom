require 'pp'
require 'ostruct'
require 'yaml'

require 'rom-relation'
require 'rom-mapper'
require 'rom/support/axiom/adapter/in_memory'
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

ROM_ENV     = ROM::Environment.coerce(:test => "in_memory://test")
ROM_ADAPTER = ENV.fetch('ROM_ADAPTER', :in_memory).to_sym

include ROM

Bogus.configure do |config|
  config.search_modules << ROM
end

RSpec.configure do |config|
  config.include(SpecHelper)
end
