# encoding: utf-8

require 'spec_helper'

describe 'Mapping relations' do
  let!(:env)   { Environment.coerce(:test => 'memory://test') }
  let!(:model) { mock_model(:id, :name) }

  specify 'I can define a relation and its mapping' do
    schema = Schema.build do
      base_relation :users do
        repository :test

        attribute :id,        Integer
        attribute :user_name, String

        key :id
      end
    end

    env.load_schema(schema)

    # TODO: replace that with mapper DSL once ready
    header = Mapper::Header.build(schema[:users].header, map: { user_name: :name })
    mapper = Mapper.build(header, model)

    users  = Relation.build(env.repository(:test).get(:users), mapper)

    jane = model.new(id: 1, name: 'Jane')

    users.insert(jane)

    expect(users.to_a).to eql([jane])
  end
end
