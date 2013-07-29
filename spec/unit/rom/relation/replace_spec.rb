# encoding: utf-8

require 'spec_helper'

describe Relation, '#replace' do
  subject(:relation) { described_class.new(users, mapper) }

  include_context 'Relation'

  it 'replaces the relation with a new one' do
    expect(relation.replace([user2]).all).to eq([user2])
  end
end
