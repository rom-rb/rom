require 'spec_helper'

describe Relation::Graph::Node::Name, '#left' do
  subject { object.left }

  let(:object) { described_class.new(left, right, relationship) }

  let(:left)         { :foo }
  let(:right)        { :bar }
  let(:relationship) { mock('relationship', :operation => mock, :target_model => mock) }

  it { should be(left) }
end
