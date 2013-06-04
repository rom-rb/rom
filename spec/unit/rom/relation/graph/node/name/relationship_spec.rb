require 'spec_helper'

describe Relation::Graph::Node::Name, '#relationship' do
  subject { object.relationship }

  let(:object) { described_class.new(left, right, relationship) }

  let(:left)         { :foo }
  let(:right)        { :bar }
  let(:relationship) { mock('relationship', :operation => mock, :target_model => mock) }

  it { should be(relationship) }
end
