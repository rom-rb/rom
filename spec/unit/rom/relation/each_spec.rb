# encoding: utf-8

require 'spec_helper'

describe Relation, '#each' do
  include_context 'Relation'

  context 'with a block' do
    it 'yields objects' do
      retval = relation.each do |tuple|
        expect(tuple).to be_instance_of(model)
      end

      expect(retval).to be(relation)
    end
  end

  context 'without a block' do
    it 'returns enumerator' do
      expect(relation.each).to be_instance_of(Enumerator)
    end
  end
end
