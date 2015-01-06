require 'rom/adapter/memory'
require 'rom/adapter/lint/test'

require 'minitest/autorun'

class MemoryAdapterLintTest < Minitest::Test
  include ROM::Adapter::Lint::TestAdapter

  def setup
    @adapter = ROM::Adapter::Memory
    @uri = "memory://localhost/test"
  end
end

class MemoryAdapterDatasetLintTest < Minitest::Test
  include ROM::Adapter::Lint::TestEnumerableDataset

  def setup
    @data  = [{ name: 'Jane', age: 24 }, { name: 'Joe', age: 25 }]
    @dataset = ROM::Adapter::Memory::Dataset.new(@data)
  end
end
