# frozen_string_literal: true

require "rom/core"
require "rom/memory"
require "rom/lint/test"

require "minitest/autorun"

class MemoryRepositoryLintTest < Minitest::Test
  include ROM::Lint::TestGateway

  def setup
    @gateway = ROM::Memory::Gateway
    @identifier = :memory
  end

  def gateway_instance
    ROM::Memory::Gateway.new
  end
end

class MemoryDatasetLintTest < Minitest::Test
  include ROM::Lint::TestEnumerableDataset

  def setup
    @data = [{name: "Jane", age: 24}, {name: "Joe", age: 25}]
    @dataset = ROM::Memory::Dataset.new(@data)
  end
end
