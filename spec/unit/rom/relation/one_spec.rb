# encoding: utf-8

require 'spec_helper'

describe Relation, '#one' do
  include_context 'Relation'

  it 'limits the underlying relation' do
    stub(relation).take(2) { [john] }
    expect(relation.one).to eql(john)
    relation.should have_received.take(2)
  end

  context 'when no block is given' do
    context 'when one tuple is returned' do
      it 'returns one object' do
        expect(relation.restrict(name: 'John').one).to eql(john)
      end
    end

    context 'when no tuple is returned' do
      it 'raises NoTuplesError' do
        expect { relation.restrict(name: 'unknown').one }.to raise_error(NoTuplesError)
      end
    end

    context 'when more than one tuple is returned' do
      let(:header) { [[:id, Integer], [:name, String]] }
      let(:users)  { Axiom::Relation.new(header, [[1, 'Jane'], [2, 'Jane']]) }
      let(:model)  { mock_model(:id, :name) }

      it 'raises ManyTuplesError' do
        expect { relation.restrict(name: 'Jane').one }.to raise_error(ManyTuplesError)
      end
    end
  end

  context 'when a block is given' do
    let(:block) { ->() { raise error } }

    context 'when no tuple is returned' do
      let(:error) { Class.new(StandardError) }

      it 'invokes the block' do
        expect { relation.restrict(name: 'unknown').one(&block) }.to raise_error(error)
      end
    end
  end
end
