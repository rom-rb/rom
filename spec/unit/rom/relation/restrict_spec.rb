require 'spec_helper'

describe Relation, '#restrict' do
  subject(:relation) { described_class.new(users, mapper) }

  include_context 'Relation'

  it 'restricts the relation' do
    expect(relation.restrict(:name => 'Jane').all).to eq([user2])
  end
end
