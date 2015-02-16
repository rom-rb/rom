# encoding: utf-8

# this is needed for guard to work, not sure why :(
require "bundler"
Bundler.setup

if RUBY_ENGINE == "rbx"
  require "codeclimate-test-reporter"
  CodeClimate::TestReporter.start
end

require 'rom'

begin
  require 'byebug'
rescue LoadError
end

root = Pathname(__FILE__).dirname

Dir[root.join('support/*.rb').to_s].each { |f| require f }
Dir[root.join('shared/*.rb').to_s].each { |f| require f }

# Namespace holding all objects created during specs
module Test
end

RSpec.configure do |config|
  config.after do
    added_constants = Test.constants
    added_constants.each { |name| Test.send(:remove_const, name) }
  end
end
