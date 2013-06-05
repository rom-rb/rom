require 'spec_helper'

describe Graph, '#node_for' do
  subject { object.node_for(relation) }

  let(:object)   { described_class.new }
  let(:name)     { 'users' }
  let(:relation) { mock_relation(name) }
  let(:node)     { object[:users] }

  before { object << relation }

  it { should be(node) }
end
