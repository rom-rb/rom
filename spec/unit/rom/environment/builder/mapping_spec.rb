# encoding: utf-8

require 'spec_helper'

describe Environment::Builder, '#mapping' do
  subject(:builder) { Environment::Builder.call(test: "memory://test") }

  let!(:schema) do
    builder.schema do
      base_relation(:users) do
        repository :test
        attribute :name, String
      end
    end
  end

  it 'sets up rom mapper' do
    builder.mapping do
      relation(:users) { map :name }
    end

    expect(builder.mappers[:users]).to be_instance_of(Mapper)
  end
end
