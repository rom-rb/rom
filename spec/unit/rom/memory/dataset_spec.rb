require 'spec_helper'
require 'rom/lint/spec'

require 'rom/memory/dataset'

describe ROM::Memory::Dataset do
  subject(:dataset) { ROM::Memory::Dataset.new(data) }

  let(:data) do
    [
      { name: 'Jane', email: 'jane@doe.org', age: 10 },
      { name: 'Jade', email: 'jade@doe.org', age: 11 },
      { name: 'Joe', email: 'joe@doe.org', age: 12 }
    ]
  end

  it_behaves_like "a rom enumerable dataset"
end
