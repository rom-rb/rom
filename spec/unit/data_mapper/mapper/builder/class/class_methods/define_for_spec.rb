require 'spec_helper'

describe DataMapper::Mapper::Builder::Class, '.define_for' do
  subject { described_class.define_for(model) }

  let(:model) { mock_model("TestModel") }

  describe "created class" do
    before do
      subject.repository(:test)
      subject.relation_name(:test_models)
    end

    it { should < Mapper::Relation::Base }

    its(:name)    { should eql("TestModelMapper") }
    its(:inspect) { should eql("<#TestModelMapper @model=TestModel @repository=test @relation_name=test_models>") }
  end
end
