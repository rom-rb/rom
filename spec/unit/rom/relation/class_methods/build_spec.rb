# encoding: utf-8

require 'spec_helper'

describe Relation, '.build' do
  subject { described_class.build(relation, mapper) }

  fake(:relation)  { Axiom::Relation }
  fake(:mapped)    { Axiom::Relation }
  fake(:optimized) { Axiom::Relation }
  fake(:mapper)    { Mapper }

  before do
    stub(mapper).call(relation) { mapped }
    stub(mapped).optimize       { optimized }
  end

  its(:relation) { should be(optimized) }
  its(:mapper)   { should be(mapper) }
end
