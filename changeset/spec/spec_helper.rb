# frozen_string_literal: true

require 'pathname'

SPEC_ROOT = Pathname(__FILE__).dirname

if ENV['COVERAGE'] == 'true'
  require 'codacy-coverage'
  Codacy::Reporter.start(partial: true)
end

require 'warning'

Warning.ignore(/sequel/)
Warning.ignore(/mysql2/)
Warning.ignore(/rspec-core/)
Warning.ignore(/__FILE__/)
Warning.ignore(/__LINE__/)
Warning.process { |w| raise w } if ENV['FAIL_ON_WARNINGS'].eql?('true')

begin
  require 'pry'
  require 'pry-byebug'
rescue LoadError
end

require 'rom-changeset'
require 'rom-sql'
require 'rom-repository'

LOGGER = Logger.new(File.open('./log/test.log', 'a'))

Dry::Core::Deprecations.set_logger!(SPEC_ROOT.join('../log/deprecations.log'))

# Make inference errors quiet
class ROM::SQL::Schema::Inferrer
  def self.on_error(*args)
    # shush
  end
end

# Namespace holding all objects created during specs
module Test
  def self.remove_constants
    constants.each(&method(:remove_const))
  end
end

base_db_uri = ENV.fetch('BASE_DB_URI', 'localhost/rom_repository')

DB_URI = if defined? JRUBY_VERSION
           "jdbc:postgresql://#{base_db_uri}"
         else
           "postgres://#{base_db_uri}"
         end

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.warnings = true
  config.filter_run_when_matching :focus

  config.after do
    Test.remove_constants
  end

  Dir[SPEC_ROOT.join('support/*.rb').to_s].each do |f|
    require f
  end

  Dir[SPEC_ROOT.join('shared/*.rb').to_s].each do |f|
    require f
  end
end
