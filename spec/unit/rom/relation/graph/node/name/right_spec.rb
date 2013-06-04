require 'spec_helper'

describe Relation::Graph::Node::Name, '#right' do
  subject { object.right }

  let(:object) { described_class.new(left, right, relationship) }

  let(:left)         { :foo }
  let(:right)        { :bar }
  let(:relationship) { mock('relationship', :operation => mock, :target_model => mock) }

  it { should be(right) }
end
