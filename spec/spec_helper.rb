require 'pathname'

if RUBY_ENGINE == 'ruby' && ENV['COVERAGE'] == 'true'
  require 'yaml'
  rubies = YAML.load(File.read(File.join(__dir__, '..', '.travis.yml')))['rvm']
  latest_mri = rubies.select { |v| v =~ /\A\d+\.\d+.\d+\z/ }.max

  if RUBY_VERSION == latest_mri
    require 'simplecov'
    SimpleCov.start do
      add_filter '/spec/'
    end
  end
end

SPEC_ROOT = root = Pathname(__FILE__).dirname

require 'dry/core/deprecations'
Dry::Core::Deprecations.set_logger!(SPEC_ROOT.join('../log/deprecations.log'))

require 'rom'

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
  config.include(SchemaHelpers)

  config.after do
    Test.remove_constants
  end

  config.around do |example|
    ConstantLeakFinder.find(example)
  end

  config.disable_monkey_patching!
  config.warnings = true
end
