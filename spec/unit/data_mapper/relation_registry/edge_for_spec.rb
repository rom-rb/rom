require 'spec_helper'

describe RelationRegistry, '#edge_for' do
  subject { object.edge_for(left, right) }

  let(:object) { described_class.new(TEST_ENGINE) }

  let(:edge)   { object.build_edge(:left_right, left, right) }
  let(:left)   { mock('left') }
  let(:right)  { mock('right') }

  before { object.add_edge(edge) }

  it { should be(edge) }
end
