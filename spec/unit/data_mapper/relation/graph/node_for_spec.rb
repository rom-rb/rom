require 'spec_helper'

describe Relation::Graph, '#node_for' do
  subject { object.node_for(relation) }

  let(:object)   { described_class.new(TEST_ENGINE) }
  let(:name)     { 'users' }
  let(:relation) { mock_relation(name) }
  let(:node)     { object[:users] }

  before { object << relation }

  it { should be(node) }
end
