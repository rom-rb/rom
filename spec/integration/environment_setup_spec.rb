# encoding: utf-8

require 'spec_helper'

describe 'Setting up environment' do
  it 'registers relations within repositories' do
    env = ROM::Environment.coerce(memory: 'memory://test')

    schema = Schema.build(env.repositories) do
      base_relation :users do
        repository :memory

        attribute :id,   Integer
        attribute :name, String

        key :id
      end
    end

    expect(schema[:users]).to be_instance_of(Axiom::Relation::Variable)
  end
end
