require 'spec_helper'

describe Engine::Veritas::Engine, '#relation_edge_class' do
  subject { object.relation_edge_class }

  let(:object) { described_class.new('postgres://localhost/test') }

  it { should be(Engine::Veritas::Edge) }
end
