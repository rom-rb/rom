# encoding: utf-8

require 'spec_helper'

describe Relation, '#first' do
  include_context 'Relation'

  context 'when limit is not provided' do
    it 'returns last object' do
      expect(relation.last.to_a).to eql([user1])
    end
  end

  context 'when limit is provided' do
    it 'returns last n-objects' do
      expect(relation.last(2).to_a).to eql([user2, user1])
    end
  end
end
