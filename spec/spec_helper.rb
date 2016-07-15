# encoding: utf-8

# this is needed for guard to work, not sure why :(
require "bundler"
Bundler.setup

if RUBY_ENGINE == "ruby" && RUBY_VERSION == '2.3.1'
  require "codeclimate-test-reporter"
  CodeClimate::TestReporter.start
end

require 'rom-sql'
require 'rom-repository'

begin
  require 'byebug'
rescue LoadError
end

root = Pathname(__FILE__).dirname
LOGGER = Logger.new(File.open('./log/test.log', 'a'))

Dir[root.join('support/*.rb').to_s].each do |f|
  require f
end

Dir[root.join('shared/*.rb').to_s].each do |f|
  require f
end

require 'rom/support/deprecations'
ROM::Deprecations.set_logger!(root.join('../log/deprecations.log'))

# Namespace holding all objects created during specs
module Test
  def self.remove_constants
    constants.each(&method(:remove_const))
  end
end

RSpec.configure do |config|
  config.after do
    Test.remove_constants
  end

  config.include(MapperRegistry)
end
