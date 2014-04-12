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

  specify 'building registry of automatically mapped relations' do
    UserWithReaders = Class.new { attr_reader :id, :name, :age; include Equalizer.new(:id, :name, :age) }

    env.mapping do
      relation(:users) do
        model UserWithReaders
        map :id, :name
        map :age, from: :user_age
      end
    end

    users = env.finalize[:users]

    jane = UserWithReaders.new
    jane.instance_variable_set("@id", 1)
    jane.instance_variable_set("@name", "Jane")
    jane.instance_variable_set("@age", 30)

    users.insert(jane)

    expect(users.to_a).to eql([jane])
  end

  specify 'setting :attribute_hash loader strategy' do
    AnimaUser = Class.new { include Anima.new(:id, :name, :age) }

    env.mapping do
      relation(:users) do
        model AnimaUser
        loader :attribute_hash
        map :id, :name
        map :age, from: :user_age
      end
    end

    users = env.finalize[:users]

    jane = AnimaUser.new(id: 1, name: 'Jane', age: 30)

    users.insert(jane)

    expect(users.to_a).to eql([jane])
  end

  specify 'setting :attribute_writers loader strategy' do
    UserWithAccessors = Class.new {
      include Equalizer.new(:id, :name, :age)
      attr_accessor :name, :age
      attr_reader :id_set, :id

      def id=(id)
        @id_set = true
        @id = id
      end
    }

    env.mapping do
      relation(:users) do
        model UserWithAccessors
        loader :attribute_accessors
        map :id, :name
        map :age, from: :user_age
      end
    end

    users = env.finalize[:users]

    jane = UserWithAccessors.new
    jane.id = 1
    jane.name = 'Jane'
    jane.age = 30

    users.insert(jane)

    expect(users.to_a).to eql([jane])
    expect(jane.id_set).to be(true)
  end

  specify 'providing custom mapper' do
    custom_model  = mock_model(:id, :name, :user_age)
    custom_mapper = TestMapper.new(schema[:users].header, custom_model)

    env.mapping do
      relation(:users, custom_mapper)
    end

    users = env.finalize[:users]

    jane = custom_model.new(id: 1, name: 'Jane', user_age: 30)

    users.insert(jane)

    expect(users.to_a).to eql([jane])
  end
end
