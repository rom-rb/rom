# encoding: utf-8

require 'spec_helper'

describe Relation, '.build' do
  subject { described_class.build(relation, mapper) }

  fake(:relation)        { Axiom::Relation }
  fake(:mapped_relation) { Axiom::Relation }
  fake(:mapper)          { Mapper }

  before do
    stub(mapper).call(relation)    { mapped_relation }
    stub(mapped_relation).optimize { mapped_relation }
  end

  its(:relation) { should be(mapped_relation) }
  its(:mapper)   { should be(mapper) }
end
