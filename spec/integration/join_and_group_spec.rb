# encoding: utf-8

require 'spec_helper'

describe 'Joining and grouping relations' do
  let(:env) do
    Environment.setup(test: 'memory://test') do
      schema do
        base_relation :users do
          repository :test

          attribute :user_id, Integer
          attribute :name, String

          key :user_id
        end

        base_relation :tasks do
          repository :test

          attribute :id, Integer
          attribute :user_id, Integer
          attribute :title, String

          key :id
        end
      end

      mapping do
        relation(:users) do
          model User
          map :user_id, :name
        end

        relation(:tasks) do
          model Task
          map :id, :user_id, :title
        end
      end
    end
  end

  before do
    User = mock_model(:user_id, :name, :tasks)
    Task = mock_model(:id, :user_id, :title)

    env.schema[:users].insert([[1, 'Jane']])
    env.schema[:tasks].insert([[2, 1, 'Task 1'], [3, 1, 'Task 2']])
  end

  after do
    Object.send(:remove_const, :User) if defined?(User)
    Object.send(:remove_const, :Task) if defined?(Task)
  end

  specify 'loading a user with grouped tasks' do
    users = env[:users]
    tasks = env[:tasks]

    loaded_user = users.join(tasks).group(:tasks => tasks).project([:user_id, :name, :tasks]).one

    tuple = {
      :name => 'Jane',
      :tasks => [
        { :id => 2, :user_id => 1, :title => 'Task 1' },
        { :id => 3, :user_id => 1, :title => 'Task 2' }
      ]
    }

    task1 = Task.new(tuple[:tasks].first)
    task2 = Task.new(tuple[:tasks].last)
    user = User.new(:name => tuple[:name], :tasks => [task1, task2])

    expect(loaded_user).to eql(user)
  end
end
