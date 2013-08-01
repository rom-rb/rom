# encoding: utf-8

require 'spec_helper'

describe Relation, '#first' do
  include_context 'Relation'

  context 'when limit is not provided' do
    it 'returns first object' do
      expect(relation.first.to_a).to eql([john])
    end
  end

  context 'when limit is provided' do
    it 'returns first n-objects' do
      expect(relation.first(2).to_a).to eql([john, jane])
    end
  end
end
