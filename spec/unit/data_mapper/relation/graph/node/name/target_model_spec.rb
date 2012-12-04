require 'spec_helper'

describe Relation::Graph::Node::Name, '#target_model' do
  subject { object.target_model }

  let(:object) { described_class.new(left, right, relationship) }

  let(:left)         { :foo }
  let(:right)        { :bar }
  let(:relationship) { mock('relationship', :operation => mock, :target_model => target_model) }
  let(:target_model) { mock('target_model') }

  it { should be(target_model) }
end
