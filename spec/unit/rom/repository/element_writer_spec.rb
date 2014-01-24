# encoding: utf-8

require 'spec_helper'

describe Repository, '#[]=' do
  subject { object[:users] }

  before do
    object[:users] = relation
  end

  let(:object)   { Repository.build(:test, Addressable::URI.parse('memory://test')) }
  let(:relation) { Axiom::Relation::Base.new(:users, []) }

  it { should eq(relation) }

  it { should be_instance_of(Axiom::Relation::Variable::Materialized) }
end
