require 'spec_helper'

describe Engine::VeritasEngine, '#base_relation' do
  subject { object.relation_node_class }

  let(:object) { described_class.new('postgres://localhost/test') }

  it { should be(RelationRegistry::RelationNode::VeritasRelation) }
end
