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
       priority: 'very-high' },
     { name: 'Jade',
       street: 'Street 2',
       zipcode: '312',
       title: nil,
       priority: nil },
     { name: 'Joe',
       street: nil,
       zipcode: nil,
       title: 'Swim',
       priority: 'medium' },
     { name: 'John',
       street: nil,
       zipcode: nil,
       title: nil,
       priority: nil }
    ]
  end

  it 'transforms a tuple' do
    expect(transformer.call(relation)).to eql([
      { name: 'Jane',
        address: { street: 'Street 1', zipcode: '123' },
        tasks: [
          { title: 'Sing a song', priority: 'high' },
          { title: 'Relax', priority: 'very-high' }
        ]
      }, {
        name: 'Jade',
        address: { street: 'Street 2', zipcode: '312' },
        tasks: []
      }, {
        name: 'Joe',
        address: nil,
        tasks: [{ title: 'Swim', priority: 'medium' }]
      }, {
        name: 'John',
        address: nil,
        tasks: []
      }
    ])
  end

  it 'skip transforming if tuple is empty' do
    expect(transformer.call([])).to eql([])
  end
end
