require 'spec_helper'

describe Graph, '#[]' do
  subject { object[name.to_sym] }

  let(:object)   { described_class.new }
  let(:name)     { 'users' }
  let(:relation) { mock_relation(name) }
  let(:node)     { object.nodes.first }

  before { object << relation }

  it { should be(node) }
end
