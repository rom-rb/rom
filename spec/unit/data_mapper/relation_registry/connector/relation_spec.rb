require 'spec_helper'

describe RelationRegistry::Connector, '#relation' do
  subject { object.relation }

  let(:object) { described_class.new(:users_X_addresses, edge, relationship) }

  let(:users)     { mock_relation(:users, [[:id, Integer]]) }
  let(:addresses) { mock_relation(:addresses, [[:id, Integer], [:user_id, Integer]]) }
  let(:left)      { TEST_ENGINE.relation_node_class.new(users.name, users) }
  let(:right)     { TEST_ENGINE.relation_node_class.new(addresses.name, addresses) }
  let(:edge)      { TEST_ENGINE.relation_edge_class.new(:user_address, left, right)}

  let(:relationship) { mock_relationship(:address, :source_key => :id, :target_key => :user_id) }

  it { should be_kind_of(Veritas::Algebra::Join) }
end
