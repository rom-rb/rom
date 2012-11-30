require 'spec_helper'

describe Engine::VeritasEngine, '#relation_node_class' do
  subject { object.relation_node_class }

  let(:object) { described_class.new('postgres://localhost/test') }

  it { should be(RelationRegistry::Veritas::Node) }
end
