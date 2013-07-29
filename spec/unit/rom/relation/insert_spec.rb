# encoding: utf-8

require 'spec_helper'

describe Relation, '#insert' do
  subject(:relation) { described_class.new(users, mapper) }

  let(:users)  { Axiom::Relation.new([[:name, String]], [['John']]) }
  let(:model)  { mock_model(:name) }
  let(:user)   { model.new(name: 'John') }
  let(:mapper) { TestMapper.new(users.header, model) }

  it 'inserts dumped object into relation' do
    expect(relation.insert(user).all).to include(user)
  end
end
