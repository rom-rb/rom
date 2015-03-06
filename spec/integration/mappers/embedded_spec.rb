require 'spec_helper'
require 'rom/memory'

describe 'Mappers / embedded' do
  let(:setup) { ROM.setup(:memory) }
  let(:rom) { setup.finalize }

  it 'allows mapping embedded tuples' do
    setup.relation(:users)

    setup.mappers do
      define(:users) do
        model name: 'Test::User'

        attribute :name, from: 'name'

        embedded :tasks, from: 'tasks' do
          attribute :title, from: 'title'
        end
      end
    end

    rom.relations.users << {
      'name' => 'Jane',
      'tasks' => [{ 'title' => 'Task One' }, { 'title' => 'Task Two' }]
    }

    jane = rom.relation(:users).map_with(:users).first

    expect(jane.name).to eql('Jane')
    expect(jane.tasks).to eql([{ title: 'Task One' }, { title: 'Task Two' }])
  end

  it 'allows mapping embedded tuple' do
    setup.relation(:users)

    setup.mappers do
      define(:users) do
        model name: 'Test::User'

        attribute :name, from: 'name'

        embedded :address, from: 'address', type: :hash do
          model name: 'Test::Address'
          attribute :street, from: 'street'
          attribute :city, from: 'city'
        end
      end
    end

    rom.relations.users << {
      'name' => 'Jane',
      'address' => { 'street' => 'Somewhere 1', 'city' => 'NYC' }
    }

    jane = rom.relation(:users).as(:users).first

    Test::Address.send(:include, Equalizer.new(:street, :city))

    expect(jane.name).to eql('Jane')
    expect(jane.address).to eql(Test::Address.new(street: 'Somewhere 1', city: 'NYC'))
  end
end
