# encoding: utf-8

require 'spec_helper'

describe 'Wrapped mappers' do
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

        key :id
      end
    }
  }

  let!(:env) {
    Environment.setup(test: 'memory://test')
  }

  before do
    User = mock_model(:id, :name)
    Task = mock_model(:id, :title, :user)

    env.mapping do
      users do
        model User
        map :id
        map :name
      end

      tasks do
        model Task
        map :id
        map :title
      end
    end
  end

  after do
    Object.send(:remove_const, :User) if defined?(User)
    Object.send(:remove_const, :Task) if defined?(Task)
  end

  subject(:mapper) { env[:tasks].mapper.wrap(:user => env[:users].mapper) }

  specify 'loading wrapped tuples' do

    tuple = { :id => 1, :title => 'Task 1', :user => { :id => 2, :name => 'Jane' } }

    user = User.new(tuple[:user])
    task = Task.new(:id => tuple[:id], :title => tuple[:title], :user => user)

    expect(mapper.load(tuple)).to eql(task)
  end

  specify 'dumping wrapped tuples' do
    pending

    mapper = env[:tasks].mapper.wrap(:user => env[:users].mapper)

    tuple = { :id => 1, :title => 'Task 1', :user => { :id => 2, :name => 'Jane' } }

    user = User.new(tuple[:user])
    task = Task.new(:id => tuple[:id], :title => tuple[:title], :user => user)

    expect(mapper.dump(task)).to eql(tuple)
  end
end
