require 'spec_helper'

describe Relation, '#take' do
  subject(:relation) { described_class.new(users, mapper) }

  include_context 'Relation'

  it 'returns first n-tuples' do
    expect(relation.take(2).all).to eql([user2, user1])
  end
end
