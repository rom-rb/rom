require 'spec_helper'

describe 'Setting up environment' do
  it 'registers relations within repositories' do
    schema = ROM::Schema.build do
      base_relation :users do
        repository :memory

        attribute :id,   Integer
        attribute :name, String

        key :id
      end
    end

    env = ROM::Environment.coerce(:memory => 'in_memory://test')
    env.load_schema(schema)

    repository = env.repository(:memory)

    expect(repository.get(:users)).to eq(schema[:users])
  end
end
