require 'spec_helper'

describe RelationRegistry::RelationNode::VeritasRelation, '#header' do
  subject { object.header }

  let(:object)   { described_class.new(:users, relation) }
  let(:relation) { mock('relation', :header => header) }
  let(:header)   { [] }

  it { should be(header) }
end
