# encoding: utf-8

# this is needed for guard to work, not sure why :(
require "bundler"
Bundler.setup

if RUBY_ENGINE == "rbx"
  require "codeclimate-test-reporter"
  CodeClimate::TestReporter.start
end

require 'virtus'
require 'rom'
require 'rom/adapter/memory'

root = Pathname(__FILE__).dirname

Dir[root.join('support/*.rb').to_s].each { |f| require f }
Dir[root.join('shared/*.rb').to_s].each { |f| require f }

RSpec.configure do |config|
  config.expect_with :rspec, :minitest

  config.before do
    @constants = Object.constants
    @adapters = ROM::Adapter.adapters
  end

  config.after do
    added_constants = Object.constants - @constants
    added_constants.each { |name| Object.send(:remove_const, name) }

    added_adapters = ROM::Adapter.adapters - @adapters
    added_adapters.each { |adapter| ROM::Adapter.adapters.delete(adapter) }
  end
end
