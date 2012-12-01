require 'spec_helper'

describe Engine::Veritas::Engine, '#relation_node_class' do
  subject { object.relation_node_class }

  let(:object) { described_class.new('postgres://localhost/test') }

  it { should be(Engine::Veritas::Node) }
end
