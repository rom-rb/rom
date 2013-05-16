require 'spec_helper'

describe Relation::Mapper, '.from' do
  subject { described_class.from(other, name) }

  let(:model)        { mock_model(:TestModel) }
  let(:target_model) { mock_model(:Address) }

  let(:other)        { mock_mapper(model, [ attribute ], [ relationship ]) }
  let(:attribute)    { mock_attribute(:id, Integer) }
  let(:relationship) { mock_relationship(:address, :source_model => model, :target_model => target_model) }

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
