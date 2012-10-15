require 'spec_helper'

describe RelationRegistry::RelationConnector, '#relation' do
  subject { object.relation }

  let(:object) { described_class.new(relationship, left, right) }

  let(:left)  { RelationRegistry::RelationNode.new(mock_relation(:users, [[:id, Integer]])) }
  let(:right) { RelationRegistry::RelationNode.new(mock_relation(:addresses, [[:id, Integer]])) }

  let(:relationship) { mock_relationship(:address, :source_key => :id, :target_key => :id) }

  it { should be_kind_of(Veritas::Algebra::Join) }
end
