# encoding: utf-8

require 'spec_helper'

describe Relation, '#replace' do
  subject(:relation) { described_class.new(users, mapper) }

  include_context 'Relation'

  it 'replaces the relation with a new one' do
    expect(relation.replace([jane]).to_a).to eq([jane])
  end
end
