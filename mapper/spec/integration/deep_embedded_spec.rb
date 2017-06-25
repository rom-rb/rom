require 'spec_helper'

RSpec.describe 'Mappers / deeply embedded tuples' do
  include_context 'container'

  it 'allows mapping embedded tuples' do
    configuration.relation(:users)

    configuration.mappers do
      define(:users) do
        model name: 'Test::User'

        attribute :name, from: 'name'

        embedded :tasks, from: 'tasks' do
          attribute :title, from: 'title'

          embedded :priority, from: 'priority', type: :hash do
            attribute :value, from: 'value'
            attribute :desc, from: 'desc'
          end
        end
      end
    end

    container.relations.users << {
      'name' => 'Jane',
      'tasks' => [
        { 'title' => 'Task One', 'priority' => { 'value' => 1, 'desc' => 'high' } },
        { 'title' => 'Task Two', 'priority' => { 'value' => 3, 'desc' => 'low' } }
      ]
    }

    jane = container.relations[:users].map_with(:users).first

    expect(jane.name).to eql('Jane')

    expect(jane.tasks).to eql([
      { title: 'Task One', priority: { value: 1, desc: 'high' } },
      { title: 'Task Two', priority: { value: 3, desc: 'low' } }
    ])
  end
end
