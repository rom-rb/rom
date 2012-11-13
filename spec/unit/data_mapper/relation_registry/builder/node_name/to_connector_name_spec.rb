require 'spec_helper'

describe RelationRegistry::Builder::NodeName, '#to_connector_name' do
  subject { object.to_connector_name }

  let(:object) { described_class.new(left, right, relationship) }
  let(:left)   { :foo }
  let(:right)  { :bar }

  context 'with no given relationship' do
    let(:relationship) { nil }

    specify do
      pending "FIXME: #{described_class}#to_connector_name with no relationship"
      expect { subject }.to_not raise_error(NoMethodError)
    end
  end

  context 'with a given relationship' do
    let(:relationship) { mock('relationship', :name => :funky_bar) }

    it { should eql(:foo_X_funky_bar) }
  end
end
