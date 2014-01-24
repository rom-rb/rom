# encoding: utf-8

require 'spec_helper'

describe Relation, '#last' do
  include_context 'Relation'

  context 'when limit is not provided' do
    it 'returns last object' do
      expect(relation.last.to_a).to eql([jade])
    end
  end

  context 'when limit is provided' do
    it 'returns last n-objects' do
      expect(relation.last(2).to_a).to eql([jack, jade])
    end
  end
end
