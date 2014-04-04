# encoding: utf-8

require 'spec_helper'

describe 'Joining and wrapping relations' do
  let(:env) {
    Environment.setup(test: 'memory://test') do |env|
      env.schema do
        base_relation :users do
          repository :test

          attribute :user_id, Integer
          attribute :name, String

          key :id
        end

        base_relation :tasks do
          repository :test

          attribute :id, Integer
          attribute :user_id, Integer
          attribute :title, String

          key :id
        end
      end

      env.mapping do
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
  }

  before do
    User = mock_model(:user_id, :name)
    Task = mock_model(:id, :user_id, :title, :user)

    env.schema[:users].insert([[2, 'Jane']])
    env.schema[:tasks].insert([[1, 2, 'Task 1']])
  end

  after do
    Object.send(:remove_const, :User) if defined?(User)
    Object.send(:remove_const, :Task) if defined?(Task)
  end

  subject(:mapper) { env[:tasks].mapper.wrap(:user => env[:users].mapper) }

  specify 'loading a task with wrapped user' do
    loaded_task = env[:tasks].join(env[:users]).wrap(:user => env[:users]).project([:id, :title, :user]).one

    tuple = { :id => 1, :user_id => 2, :title => 'Task 1', :user => { :user_id => 2, :name => 'Jane' } }

    user = User.new(tuple[:user])
    task = Task.new(:id => tuple[:id], :title => tuple[:title], :user => user)

    expect(loaded_task).to eql(task)
  end
end
