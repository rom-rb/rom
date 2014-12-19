require 'spec_helper'

describe ROM::Transformer do
  subject(:transformer) { ROM::Transformer.build(header) }

  let(:header) do
    ROM::Header.coerce([
      [:name],
      [:address, type: Hash, header: [[:street], [:zipcode]]],
      [:tasks, type: Array, header: [[:title], [:priority]]]
    ])
  end

  let(:relation) do
    [{ name: 'Jane',
       street: 'Street 1',
       zipcode: '123',
       title: 'Sing a song',
       priority: 'high' },
     { name: 'Jane',
       street: 'Street 1',
       zipcode: '123',
       title: 'Relax',
       priority: 'very-high' }]
  end

  it 'transforms a tuple' do
    expect(transformer.call(relation)).to eql([
      name: 'Jane',
      address: { street: 'Street 1', zipcode: '123' },
      tasks: [
        { title: 'Sing a song', priority: 'high' },
        { title: 'Relax', priority: 'very-high' }
      ]
    ])
  end

  it 'skip transforming if tuple is empty' do
    expect(transformer.call([])).to eql([])
  end
end
