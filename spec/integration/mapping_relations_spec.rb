# encoding: utf-8

require 'spec_helper'

describe 'Defining relation mappings' do
  let!(:schema) {
    Schema.build {
      base_relation :users do
        repository :test

        attribute :id,        Integer
        attribute :user_name, String

        key :id
      end
    }
  }

  let!(:env) {
    Environment.coerce(test: 'memory://test').load_schema(schema)
  }

  before do
    User = mock_model(:id, :name)
  end

  after do
    Object.send(:remove_const, :User)
  end

  specify 'building registry of automatically mapped relations' do
    registry = Mapping.build(env) {
      users do
        model User

        map :id
        map :user_name, to: :name
      end
    }

    users = registry[:users]

    jane = User.new(id: 1, name: 'Jane')

    users.insert(jane)

    expect(users.to_a).to eql([jane])
  end

  specify 'providing custom mapper' do
    custom_model  = mock_model(:id, :user_name)
    custom_mapper = TestMapper.new(schema[:users].header, custom_model)

    registry = Mapping.build(env) { users { mapper(custom_mapper) } }

    users = registry[:users]

    jane = custom_model.new(id: 1, user_name: 'Jane')

    users.insert(jane)

    expect(users.to_a).to eql([jane])
  end
end
