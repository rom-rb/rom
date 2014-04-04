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

require 'devtools/spec_helper'

require 'rom'

require 'bogus/rspec'

include ROM
include SpecHelper
include Morpher::NodeHelpers

TEST_ENV = Environment.setup(test: 'memory://test') do
  schema do
    base_relation :users do
      repository :test

      attribute :id,   Integer
      attribute :name, String

      key :id
    end
  end

  mapping do
    relation(:users) do
      model mock_model(:id, :name)
      map :id, :name
    end
  end
end
