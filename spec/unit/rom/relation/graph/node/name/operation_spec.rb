require 'spec_helper'

describe Relation::Graph::Node::Name, '#operation' do
  subject { object.operation }

  let(:object) { described_class.new(left, right, relationship) }

  let(:left)         { :foo }
  let(:right)        { :bar }
  let(:relationship) { mock('relationship', :operation => operation, :target_model => mock) }
  let(:operation)    { mock('operation') }

  it { should be(operation) }
end
