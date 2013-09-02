# encoding: utf-8

# SimpleCov MUST be started before require 'rom-relation'
#
if ENV['COVERAGE'] == 'true'
  require 'simplecov'
  require 'coveralls'

  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::HTMLFormatter,
    Coveralls::SimpleCov::Formatter
  ]

  SimpleCov.start do
    command_name 'spec:unit'

    add_filter 'config'
    add_filter 'lib/rom/support'
    add_filter 'spec'
  end
end

require 'rom-relation'
require 'rom-mapper'

require 'devtools/spec_helper'
require 'bogus/rspec'

include ROM

ROM_ENV     = Environment.setup(test: 'memory://test')
ROM_ADAPTER = ENV.fetch('ROM_ADAPTER', :in_memory).to_sym

Bogus.configure do |config|
  config.search_modules << ROM
end

RSpec.configure do |config|
  config.include(SpecHelper)
end
