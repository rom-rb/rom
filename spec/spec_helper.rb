# encoding: utf-8

# this is needed for guard to work, not sure why :(
require "bundler"
Bundler.setup

if RUBY_ENGINE == "rbx"
  require "codeclimate-test-reporter"
  CodeClimate::TestReporter.start
end

require 'rom'
require 'anima'

begin
  require 'byebug'
rescue LoadError
end

require "active_support"
ROM::Inflector = ActiveSupport::Inflector

root = Pathname(__FILE__).dirname

Dir[root.join('support/*.rb').to_s].each { |f| require f }
Dir[root.join('shared/*.rb').to_s].each { |f| require f }

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

  config.around do |example|
    ConstantLeakFinder.find(example)
  end
end
