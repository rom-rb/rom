require 'spec_helper'

describe 'Mappers / deeply embedded tuples' do
  let(:setup) { ROM.setup('memory://test') }
  let(:rom) { setup.finalize }

  it 'allows mapping embedded tuples' do
    setup.schema do
      base_relation(:users) do
        repository :default
        attribute 'name'
        attribute 'tasks'
      end
    end

    setup.relation(:users)

    setup.mappers do
      define(:users) do
        model name: 'User'

        attribute :name, from: 'name'

        embedded :tasks, from: 'tasks' do
          attribute :title, from: 'title'

          embedded :priority, from: 'priority', type: Hash do
            attribute :value, from: 'value'
            attribute :desc, from: 'desc'
          end
        end
      end
    end

    rom.schema.users << {
      'name' => 'Jane',
      'tasks' => [
        { 'title' => 'Task One', 'priority' => { 'value' => 1, 'desc' => 'high' } },
        { 'title' => 'Task Two', 'priority' => { 'value' => 3, 'desc' => 'low' } },
      ]
    }

    jane = rom.read(:users).to_a.first

    expect(jane.name).to eql('Jane')

    expect(jane.tasks).to eql([
      { title: 'Task One', priority: { value: 1, desc: 'high' } },
      { title: 'Task Two', priority: { value: 3, desc: 'low' } },
    ])
  end
end
