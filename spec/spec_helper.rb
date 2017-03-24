# encoding: utf-8

# this is needed for guard to work, not sure why :(
require "bundler"
Bundler.setup

if ENV['COVERAGE'] == 'true' && RUBY_ENGINE == 'ruby' && RUBY_VERSION >= '2.4.0' && ENV['CI'] == 'true'
  require 'simplecov'
  SimpleCov.start do
    add_filter '/spec/'
  end
end

require 'rom-sql'
require 'rom-repository'

begin
  require 'byebug'
rescue LoadError
end

root = Pathname(__FILE__).dirname
LOGGER = Logger.new(File.open('./log/test.log', 'a'))

require 'dry/core/deprecations'
Dry::Core::Deprecations.set_logger!(root.join('../log/deprecations.log'))

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

warning_api_available = RUBY_VERSION >= '2.4.0'

module SileneceWarnings
  def warn(str)
    if str['/sequel/'] || str['/rspec-core']
      nil
    else
      super
    end
  end
end

DB_URI = if defined? JRUBY_VERSION
           'jdbc:postgresql://localhost/rom_repository'
         else
           'postgres://localhost/rom_repository'
         end

Warning.extend(SileneceWarnings) if warning_api_available

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.warnings = true

  config.after do
    Test.remove_constants
  end

  Dir[root.join('support/*.rb').to_s].each do |f|
    require f
  end

  Dir[root.join('shared/*.rb').to_s].each do |f|
    require f
  end

  config.include(MapperRegistry)
end
