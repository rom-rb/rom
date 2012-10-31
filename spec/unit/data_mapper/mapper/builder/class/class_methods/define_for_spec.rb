require 'spec_helper'

describe DataMapper::Mapper::Builder::Class, '.define_for' do
  subject { described_class.define_for(model) }

  let(:model) { mock_model("TestModel") }

  describe "created class" do
    its(:name)    { should eql("TestModelMapper") }
    its(:inspect) { should eql("<#TestModelMapper @model=TestModel>") }

    context "without a parent" do
      it { should < Mapper::Relation }
    end

    context "with a parent" do
      subject { described_class.define_for(model, Mapper) }

      it { should < Mapper }
    end

    context "with a name" do
      subject { described_class.define_for(model, Mapper, 'TestModel_Mapper') }

      its(:name) { should eql('TestModel_Mapper') }
    end
  end
end
