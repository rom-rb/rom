require 'rom/adapter/memory'
require 'rom/adapter/lint/test'

require 'minitest/autorun'

class MemoryAdapterLintTest < MiniTest::Test
  include ROM::Adapter::Lint::TestAdapter

  def setup
    @adapter = ROM::Adapter::Memory
  end
end

class MemoryAdapterDatasetLintTest < MiniTest::Test
  include ROM::Adapter::Lint::TestEnumerableDataset

  def setup
    @data  = [{ name: 'Jane', age: 24 }, { name: 'Joe', age: 25 }]
    @dataset = ROM::Adapter::Memory::Dataset.new(@data, [:name, :age])
  end
end
