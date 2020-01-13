# frozen_string_literal: true

require 'pathname'

SPEC_ROOT = root = Pathname(__FILE__).dirname

if ENV['COVERAGE'] == 'true'
  require 'codacy-coverage'
  Codacy::Reporter.start(partial: true)
end

require 'rom/core'

Dir[root.join('support/*.rb').to_s].each do |f|
  require f unless f.include?('coverage')
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
  config.after do
    Test.remove_constants
  end

  config.disable_monkey_patching!
  config.filter_run_when_matching :focus
  config.warnings = true
end
