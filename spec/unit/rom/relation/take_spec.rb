# encoding: utf-8

require 'spec_helper'

describe Relation, '#take' do
  include_context 'Relation'

  it 'returns first n-tuples' do
    expect(relation.take(2).to_a).to eql([user2, user1])
  end
end
