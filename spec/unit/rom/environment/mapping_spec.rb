# encoding: utf-8

require 'spec_helper'

describe Environment, '#mapping' do
  include_context 'Environment'

  let!(:schema) do
    object.schema do
      base_relation(:users) do
        repository :test
        attribute :name, String
      end
    end
  end

  before do
    object.mapping do
      users { map :name }
    end
  end

  it 'sets up rom relations' do
    expect(object[:users]).to be_instance_of(Relation)
  end
end
