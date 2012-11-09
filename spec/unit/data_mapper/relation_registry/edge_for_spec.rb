require 'spec_helper'

describe RelationRegistry, '#edge_for' do
  subject { object.edge_for(left, right) }

  let(:object) { described_class.new(TEST_ENGINE) }

  let(:edge)         { object.build_edge(:left_right, left, right, join_key_map) }
  let(:left)         { mock('left') }
  let(:right)        { mock('right') }
  let(:join_key_map) { mock('join_key_map') }

  before { object.add_edge(edge) }

  it { should be(edge) }
end
