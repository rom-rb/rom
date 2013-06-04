require 'spec_helper'

describe Relation::Graph::Node, '#restrict' do
  subject { object.restrict(query, &block) }

  let(:object)      { described_class.new(:users, relation) }
  let(:relation)    { mock('relation') }
  let(:restriction) { mock('restriction') }
  let(:query)       { {} }
  let(:block)       { Proc.new {} }

  before do
    relation.should_receive(:restrict).with(query, &block).and_return(restriction)
  end

  it { should be_instance_of(described_class) }

  its(:relation) { should be(restriction) }
  its(:header)   { should be(object.header) }
end
