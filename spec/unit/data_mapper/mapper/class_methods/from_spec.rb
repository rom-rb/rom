require 'spec_helper'

describe Mapper, '.from' do
  subject { described_class.from(other, name) }

  let(:model) {
    mock_model(:TestModel)
  }

  let(:other) {
    model_class = model
    address_model = mock_model('Address')

    Class.new(described_class) {
      model model_class
      map :id, Integer
      has 1, :address, address_model
    }
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

      it "copies relationships" do
        subject.relationships[:address].should eql(other.relationships[:address])
      end
    end
  end
end
