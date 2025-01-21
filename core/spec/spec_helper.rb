# frozen_string_literal: true

require 'pathname'

SPEC_ROOT = root = Pathname(__FILE__).dirname

if ENV['COVERAGE'] == 'true'
  require 'codacy-coverage'
  Codacy::Reporter.start(partial: true)
end

require 'warning'
require 'dry/core'

Warning.ignore(/__FILE__/)
Warning.ignore(/__LINE__/)

if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('3.4')
  Warning[:strict_unused_block] = true
end

Warning.process { |w| raise w } if ENV['FAIL_ON_WARNINGS'].eql?('true')

Dry::Core::Deprecations.set_logger!(SPEC_ROOT.join('../log/deprecations.log'))

%w[pry-byebug debug pry].each do |gem|
  require gem
rescue LoadError
  # ignore
else
  break
end

module SpecProfiler
  def report(*)
    require 'hotch'

    Hotch() do
      super
    end
  end
end

require 'rom/core'

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
  config.filter_run_when_matching :focus

  config.reporter.extend(SpecProfiler) if ENV['PROFILE'] == 'true'
end
