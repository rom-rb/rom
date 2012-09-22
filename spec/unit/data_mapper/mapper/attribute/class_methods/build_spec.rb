require 'spec_helper'

describe DataMapper::Mapper::Attribute, '.build' do
  subject { described_class.build(name, options) }

  let(:name)       { :title }
  let(:collection) { false }
  let(:options)    { { :type => type, :collection => collection } }

  context "when type is a veritas primitive attribute" do
    let(:type) { String }

    it { should be_instance_of(described_class::Primitive) }
  end

  context "when type is not a primitive" do
    let(:type)       { mock_model(:TestModel) }
    let(:collection) { false }

    it { should be_instance_of(described_class::EmbeddedValue) }
  end

  context "when collection is set" do
    let(:type)       { mock_model(:TestModel) }
    let(:collection) { true }

    it { should be_instance_of(described_class::EmbeddedCollection) }
  end
end
