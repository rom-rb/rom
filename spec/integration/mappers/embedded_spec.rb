require 'spec_helper'

describe 'Mappers / embedded' do
  let(:setup) { ROM.setup('memory://test') }
  let(:rom) { setup.finalize }

  before do
    setup.schema do
      base_relation(:users) do
        repository :default
        attribute 'name'
        attribute 'tasks'
        attribute 'address'
      end
    end

    setup.relation(:users)
  end

  it 'allows mapping embedded tuples' do
    setup.mappers do
      define(:users, inherit_header: false) do
        model name: 'User'

        attribute :name, from: 'name'

        embedded :tasks, from: 'tasks' do
          attribute :title, from: 'title'
        end
      end
    end

    rom.schema.users << {
      'name' => 'Jane',
      'tasks' => [{ 'title' => 'Task One' }, { 'title' => 'Task Two' }]
    }

    jane = rom.read(:users).to_a.first

    expect(jane.name).to eql('Jane')
    expect(jane.tasks).to eql([{ title: 'Task One' }, { title: 'Task Two' }])
  end

  it 'allows mapping embedded tuple' do
    setup.mappers do
      define(:users, inherit_header: false) do
        model name: 'User'

        attribute :name, from: 'name'

        embedded :address, from: 'address', type: Hash do
          model name: 'Address'
          attribute :street, from: 'street'
          attribute :city, from: 'city'
        end
      end
    end

    rom.schema.users << {
      'name' => 'Jane',
      'address' => { 'street' => 'Somewhere 1', 'city' => 'NYC' }
    }

    jane = rom.read(:users).to_a.first

    Address.send(:include, Equalizer.new(:street, :city))

    expect(jane.name).to eql('Jane')
    expect(jane.address).to eql(Address.new(street: 'Somewhere 1', city: 'NYC'))
  end
end
