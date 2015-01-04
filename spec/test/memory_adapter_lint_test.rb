require 'rom/adapter/memory'
require 'rom/adapter/lint/test'

require 'minitest/autorun'

class MemoryAdapterLintTest < MiniTest::Unit::TestCase
  include ROM::Adapter::Lint::TestAdapter

  def setup
    @adapter = ROM::Adapter::Memory
  end
end
