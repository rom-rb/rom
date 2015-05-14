require 'spec_helper'
require 'rom/lint/spec'
require 'rom/memory/dataset'

describe ROM::Memory::Dataset do
  subject(:dataset) { described_class.new(data) }

  let(:data) do
    [
      { name: 'Jane', email: 'jane@doe.org', age: 10 },
      { name: 'Jade', email: 'jade@doe.org', age: 11 },
      { name: 'Joe', email: 'joe@doe.org', age: 12 }
    ]
  end

  it_behaves_like "a rom enumerable dataset"

  describe '#project' do
    it 'projects tuples with the provided keys' do
      expect(dataset.project(:name, :age)).to match_array([
        { name: 'Jane', age: 10 },
        { name: 'Jade', age: 11 },
        { name: 'Joe', age: 12 }
      ])
    end
  end

  describe '#restrict' do
    it 'restricts data using criteria hash' do
      expect(dataset.restrict(age: 10)).to match_array([
        { name: 'Jane', email: 'jane@doe.org', age: 10 }
      ])

      expect(dataset.restrict(age: 10.0)).to match_array([])
    end

    it 'restricts data using block' do
      expect(dataset.restrict { |tuple| tuple[:age] > 10 }).to match_array([
        { name: 'Jade', email: 'jade@doe.org', age: 11 },
        { name: 'Joe', email: 'joe@doe.org', age: 12 }
      ])
    end
  end

  describe '#order' do
    it 'sorts data using provided attribute names' do
      expect(dataset.order(:name).to_a).to eq([
        { name: 'Jade', email: 'jade@doe.org', age: 11 },
        { name: 'Jane', email: 'jane@doe.org', age: 10 },
        { name: 'Joe', email: 'joe@doe.org', age: 12 }
      ])
    end
  end
end
