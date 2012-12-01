require 'spec_helper'

describe RelationRegistry::NodeName, '#to_sym' do
  subject { object.to_sym }

  let(:object) { described_class.new(left, right, relationship) }

  let(:left)         { :foo }
  let(:right)        { :bar }
  let(:relationship) { mock('relationship', :operation => mock, :target_model => mock) }

  it { should eql(:foo_X_bar) }
end
