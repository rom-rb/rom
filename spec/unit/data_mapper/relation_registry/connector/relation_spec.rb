require 'spec_helper'

describe RelationRegistry::Connector, '#relation' do
  subject { object.relation }

  let(:object) { described_class.new(edge, relationship) }

  let(:users)     { mock_relation(:users, [[:id, Integer]]) }
  let(:addresses) { mock_relation(:addresses, [[:id, Integer], [:user_id, Integer]]) }
  let(:left)      { RelationRegistry::RelationNode.new(users.name, users) }
  let(:right)     { RelationRegistry::RelationNode.new(addresses.name, addresses) }
  let(:edge)      { RelationRegistry::RelationEdge.new(:user_address, left, right)}

  let(:relationship) { mock_relationship(:address, :source_key => :id, :target_key => :user_id) }

  it { should be_kind_of(Veritas::Algebra::Join) }
end
