# encoding: utf-8

require 'spec_helper'

describe Relation, '.build' do
  subject { described_class.build(relation, mapper) }

  fake(:relation) { Axiom::Relation }
  fake(:mapper)   { Mapper }

  let(:mapped_relation) { mock('mapped_relation') }

  before do
    stub(mapper).call(relation) { mapped_relation }
  end

  its(:relation) { should be(mapped_relation) }
end
