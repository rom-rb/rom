require 'spec_helper'

describe Mapper, '.from' do
  subject { described_class.from(other, name) }

  let(:model) {
    mock_model('TestModel')
  }

  let(:other) {
    klass = Class.new(described_class) {
      map :id, Integer
    }
    klass.model(model)
    klass
  }

  context "with another mapper" do
    context "without a name" do
      let(:name) { nil }

      its(:model) { should be(model) }
      its(:name)  { should eql("TestModelMapper") }
    end

    context "with a name" do
      let(:name) { 'AnotherTestModelMapper' }

      its(:model) { should be(model) }
      its(:name)  { should eql(name) }

      it "copies attributes" do
        subject.attributes[:id].should be_instance_of(Attribute::Primitive)
      end
    end
  end
end
