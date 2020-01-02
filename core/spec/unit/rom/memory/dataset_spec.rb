require 'spec_helper'
require 'rom/lint/spec'

require 'rom/memory/dataset'

RSpec.describe ROM::Memory::Dataset do
  subject(:dataset) { ROM::Memory::Dataset.new(data) }

  let(:data) do
    [
      { name: 'Jane', email: 'jane@doe.org', age: 10 },
      { name: 'Jade', email: 'jade@doe.org', age: 11 },
      { name: 'Joe', email: 'joe@doe.org', age: 12 }
    ]
  end

  it_behaves_like 'a rom enumerable dataset'

  describe 'subclassing' do
    it 'supports options' do
      descendant = Class.new(ROM::Memory::Dataset) do
        option :path
      end

      dataset = descendant.new([1, 2, 3], path: '/data')

      expect(dataset.to_a).to eql([1, 2, 3])
      expect(dataset.path).to eql('/data')
    end
  end
end
