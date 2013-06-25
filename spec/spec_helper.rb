# SimpleCov MUST be started before require 'rom-mapper'
#
if ENV['COVERAGE'] == 'true'
  require 'simplecov'
  require 'coveralls'

  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::HTMLFormatter,
    Coveralls::SimpleCov::Formatter
  ]

  SimpleCov.start do
    command_name 'spec:unit'

    add_filter 'config'
    add_filter 'spec'

    #minimum_coverage 98.10  # 0.10 lower under JRuby
  end

end

require 'devtools'
Devtools.init_spec_helper

require 'axiom'
require 'rom-mapper'

require 'bogus/rspec'

Bogus.configure do |config|
  config.search_modules << ROM
end

RSpec.configure do |config|
  config.mock_with Bogus::RSpecAdapter
end

include ROM

def mock_model(*attributes)
  Class.new {
    include Equalizer.new(*attributes)

    attributes.each { |attribute| attr_accessor attribute }

    def initialize(attrs)
      attrs.each { |name, value| send("#{name}=", value) }
    end
  }
end
