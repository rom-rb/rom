# encoding: utf-8

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
    add_filter 'lib/rom/support'
    add_filter 'spec'
  end
end

require 'rom-mapper'
require 'axiom'

require 'devtools/spec_helper'
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

    def initialize(attrs, &block)
      attrs.each { |name, value| send("#{name}=", value) }
      instance_eval(&block) if block
    end
  }
end
