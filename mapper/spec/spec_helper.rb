require 'pathname'

SPEC_ROOT = Pathname(__FILE__).dirname

if RUBY_ENGINE == 'ruby' && ENV['COVERAGE'] == 'true'
  require 'yaml'
  rubies = YAML.load(File.read(SPEC_ROOT.join('../../.travis.yml')))['rvm']
  latest_mri = rubies.select { |v| v =~ /\A\d+\.\d+.\d+\z/ }.max

  if RUBY_VERSION == latest_mri
    require 'simplecov'
    SimpleCov.start do
      add_filter '/spec/'
    end
  end
end

# this is needed for guard to work, not sure why :(
require "bundler"
Bundler.setup

require 'rom-mapper'
require 'rom-core'
require 'dry-struct'

begin
  require 'byebug'
rescue LoadError
end

Dir[SPEC_ROOT.join('support/*.rb').to_s].each do |f|
  require f
end
Dir[SPEC_ROOT.join('shared/*.rb').to_s].each do |f|
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

  config.disable_monkey_patching!

  config.warnings = true
end
