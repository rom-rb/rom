require 'rom/adapter/memory'
require 'rom/adapter/lint/spec'

describe ROM::Adapter::Memory do
  include_examples "adapter"

  let(:adapter) { ROM::Adapter::Memory }
  let(:uri) { "memory://localhost/test" }
  let(:adapter_instance) { ROM::Adapter.setup(uri) }

  describe ROM::Adapter::Memory::Dataset do
    include_examples "enumerable dataset"

    let(:data) { [{ name: 'Jane', age: 24 }, { name: 'Joe', age: 25 }] }
    let(:dataset) { ROM::Adapter::Memory::Dataset.new(data) }
  end
end
