# encoding: utf-8

require 'spec_helper'

describe 'Grouped mappers' do
  let(:env) do
    Environment.setup(test: 'memory://test') do |env|
      env.schema do
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

          key :id
        end
      end

      env.mapping do
        relation(:users) do
          model User
          map :id, :name
        end

        relation(:tasks) do
          model Task
          map :id, :title
        end
      end
    end
  end

  before do
    User = mock_model(:id, :name, :tasks)
    Task = mock_model(:id, :title)
  end

  after do
    Object.send(:remove_const, :User) if defined?(User)
    Object.send(:remove_const, :Task) if defined?(Task)
  end

  subject(:mapper) { env[:users].mapper.group(:tasks => env[:tasks].mapper) }

  specify 'loading grouped tuples' do
    tuple = {
      :id => 1,
      :name => 'Jane',
      :tasks => [
        { :id => 2, :title => 'Task 1' },
        { :id => 3, :title => 'Task 2' }
      ]
    }

    task1 = Task.new(tuple[:tasks].first)
    task2 = Task.new(tuple[:tasks].last)
    user = User.new(:id => tuple[:id], :name => tuple[:name], :tasks => [task1, task2])

    expect(mapper.load(tuple)).to eql(user)
  end

  specify 'dumping grouped tuples' do
    tuple = {
      :id => 1,
      :name => 'Jane',
      :tasks => [
        { :id => 2, :title => 'Task 1' },
        { :id => 3, :title => 'Task 2' }
      ]
    }

    task1 = Task.new(tuple[:tasks].first)
    task2 = Task.new(tuple[:tasks].last)
    user = User.new(:id => tuple[:id], :name => tuple[:name], :tasks => [task1, task2])

    expect(mapper.dump(user)).to eql([1, 'Jane', [[2, 'Task 1'], [3, 'Task 2']]])
  end
end
