# encoding: utf-8

require 'spec_helper'

describe 'Defining relation mappings' do
  let!(:schema) {
    env.schema {
      base_relation :users do
        repository :test

        attribute :id,   Integer
        attribute :name, String

        key :id
      end

      base_relation :tasks do
        repository :test

        attribute :id, Integer
        attribute :title, String

        wrap user: users.header

        key :id
      end
    }
  }

  let!(:env) {
    Environment.setup(test: 'memory://test')
  }

  before do
    User = mock_model(:id, :name)
    Task = mock_model(:id, :title)
  end

  after do
    Object.send(:remove_const, :User)
    Object.send(:remove_const, :Task)
  end

  specify 'building registry of automatically mapped relations' do
    pending "IMPLEMENT ME"

    env.mapping do
      users do
        model User

        map :id
        map :name
      end

      tasks do
        model Task

        map :id
        map :name
        map :user, model: User
      end
    end

    tasks = env[:tasks]

    user = User.new(id: 1, name: 'Jane')
    task = Task.new(id: 1, title: 'Test', user: user)

    tasks.insert(task)

    expect(tasks.to_a).to eql([task])
  end
end
