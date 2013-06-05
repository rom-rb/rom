require 'spec_helper'

describe Graph::Node, '#restrict' do
  subject { object.restrict(query, &block) }

  let(:object)      { described_class.new(:users, relation) }
  let(:restriction) { mock('restriction') }
  let(:query)       { {} }
  let(:block)       { Proc.new {} }

  fake(:relation)

  before do
    stub(relation).restrict(query) { restriction }
  end

  it { should be_instance_of(described_class) }

  its(:relation) { should be(restriction) }
  its(:header)   { should be(object.header) }
end
