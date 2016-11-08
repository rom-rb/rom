# encoding: utf-8

# this is needed for guard to work, not sure why :(
require "bundler"
Bundler.setup

if RUBY_ENGINE == 'ruby' && RUBY_VERSION='2.3.1'
  require "simplecov"
  SimpleCov.start do
    add_filter '/spec/'
  end
end

SPEC_ROOT = root = Pathname(__FILE__).dirname

require 'rom/support/deprecations'
ROM::Deprecations.set_logger!(SPEC_ROOT.join('../log/deprecations.log'))

require 'rom'
require 'anima'

begin
  require 'byebug'
rescue LoadError
end

Dir[root.join('support/*.rb').to_s].each do |f|
  require f
end
Dir[root.join('shared/*.rb').to_s].each do |f|
  require f
end

# Namespace holding all objects created during specs
module Test
  def self.remove_constants
    constants.each(&method(:remove_const))
  end
end

def T(*args)
  ROM::Processor::Transproc::Functions[*args]
end

RSpec.configure do |config|
  config.after do
    Test.remove_constants
  end

  config.around do |example|
    ConstantLeakFinder.find(example)
  end
end
