# encoding: utf-8

require 'spec_helper'

describe Relation, '#one' do
  include_context 'Relation'

  context 'when one tuple is returned' do
    it 'returns one object' do
      expect(relation.one(name: 'Jane')).to eql(user2)
    end
  end

  context 'when more than one tuple is returned' do
    let(:header) { [[:id, Integer], [:name, String]] }
    let(:users)  { Axiom::Relation.new(header, [[1, 'Jane'], [2, 'Jane']]) }

    it 'raises error' do
      expect { relation.one(name: 'Jane') }.to raise_error(ManyTuplesError)
    end
  end
end
