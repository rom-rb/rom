# encoding: utf-8

require 'spec_helper'

describe 'Defining relation mappings' do
  let!(:schema) {
    env.schema {
      base_relation :users do
        repository :test

        attribute :id, Integer
        attribute :user_name, String, rename: :name
        attribute :user_age, Integer

        key :id
      end
    }
  }

  let!(:env) {
    Environment.setup(test: 'memory://test')
  }

  before do
    User = mock_model(:id, :name, :age)
  end

  after do
    Object.send(:remove_const, :User)
  end

  specify 'building registry of automatically mapped relations' do
    env.mapping do
      users do
        model User
        map :id, :name
        map :age, from: :user_age
      end
    end

    users = env[:users]

    jane = User.new(id: 1, name: 'Jane', age: 30)

    users.insert(jane)

    expect(users.to_a).to eql([jane])
  end

  specify 'providing custom mapper' do
    custom_model  = mock_model(:id, :name, :user_age)
    custom_mapper = TestMapper.new(schema[:users].header, custom_model)

    env.mapping { users { mapper(custom_mapper) } }

    users = env[:users]

    jane = custom_model.new(id: 1, name: 'Jane', user_age: 30)

    users.insert(jane)

    expect(users.to_a).to eql([jane])
  end
end
