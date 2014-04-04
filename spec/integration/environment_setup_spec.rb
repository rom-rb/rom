# encoding: utf-8

require 'spec_helper'

describe 'Setting up environment' do
  let(:env) do
    ROM::Environment.setup(memory: 'memory://test') do
      schema do
        base_relation :users do
          repository :memory

          attribute :id,   Integer
          attribute :name, String

          key :id
        end
      end
    end
  end

  it 'registers relations within repositories' do
    expect(env.schema[:users]).to be_instance_of(Axiom::Relation::Variable::Materialized)
  end
end
