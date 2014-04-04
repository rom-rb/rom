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

  let(:users) { env[:users] }

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

  specify 'setting :attribute_hash loader strategy' do
    AnimaUser = Class.new { include Anima.new(:id, :name, :age) }

    env.mapping do
      users do
        model AnimaUser
        loader :attribute_hash
        map :id, :name
        map :age, from: :user_age
      end
    end

    jane = AnimaUser.new(id: 1, name: 'Jane', age: 30)

    users.insert(jane)

    expect(users.to_a).to eql([jane])
  end

  specify 'setting :attribute_writers loader strategy' do
    UserWithAccessors = Class.new {
      include Equalizer.new(:id, :name, :age)
      attr_accessor :id, :name, :age
    }

    env.mapping do
      users do
        model UserWithAccessors
        loader :attribute_writers
        map :id, :name
        map :age, from: :user_age
      end
    end

    jane = UserWithAccessors.new
    jane.id = 1
    jane.name = 'Jane'
    jane.age = 30

    users.insert(jane)

    expect(users.to_a).to eql([jane])
  end

  specify 'providing custom mapper' do
    custom_model  = mock_model(:id, :name, :user_age)
    custom_mapper = TestMapper.new(schema[:users].header, custom_model)

    env.mapping { users { mapper(custom_mapper) } }

    jane = custom_model.new(id: 1, name: 'Jane', user_age: 30)

    users.insert(jane)

    expect(users.to_a).to eql([jane])
  end
end
