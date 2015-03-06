require 'spec_helper'
require 'rom/memory'

describe 'Mappers / Symbolizing atributes' do
  let(:setup) { ROM.setup(:memory) }
  let(:rom) { setup.finalize }

  before do
    setup.relation(:users)
    setup.relation(:tasks)
  end

  it 'automatically maps all attributes using top-level settings' do
    module Test
      class UserMapper < ROM::Mapper
        relation :users

        symbolize_keys true
        prefix 'user'

        attribute :id

        wrap :details, prefix: 'first' do
          attribute :name
        end

        wrap :contact, prefix: false do
          attribute :email
        end
      end
    end

    rom.relations.users << {
      'user_id' => 123,
      'first_name' => 'Jane',
      'email' => 'jane@doe.org'
    }

    jane = rom.relation(:users).as(:users).first

    expect(jane).to eql(
      id: 123, details: { name: 'Jane' }, contact: { email: 'jane@doe.org' }
    )
  end

  it 'automatically maps all attributes using settings for wrap block' do
    module Test
      class TaskMapper < ROM::Mapper
        relation :tasks
        symbolize_keys true

        attribute :title

        wrap :details, prefix: 'task' do
          attribute :priority
          attribute :description
        end
      end
    end

    rom.relations.tasks << {
      'title' => 'Task One',
      'task_priority' => 1,
      'task_description' => 'It is a task'
    }

    task = rom.relation(:tasks).as(:tasks).first

    expect(task).to eql(
      title: 'Task One',
      details: { priority: 1, description: 'It is a task' }
    )
  end
end
