require 'spec_helper'

describe RelationRegistry::Builder::NodeName, '#left' do
  subject { object.left }

  let(:object) { described_class.new(left, right, relationship) }

  let(:left)         { :foo }
  let(:right)        { :bar }
  let(:relationship) { mock('relationship', :name => :funky_bar) }

  it { should be(left) }
end
