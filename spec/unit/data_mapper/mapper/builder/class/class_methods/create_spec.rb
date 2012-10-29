require 'spec_helper'

describe DataMapper::Mapper::Builder::Class, '.create' do
  subject { described_class.create(model, repository, &block) }

  let(:model)      { mock_model("TestModel") }
  let(:attributes) { [] }
  let(:repository) { :superstore }

  before do
    model.should_receive(:attribute_set).and_return(attributes)
    described_class.should_receive(:copy_attributes).with(subject, attributes)
  end

  context "without a block" do
    let(:block) { nil }

    specify { subject.should < DataMapper::Mapper::Relation::Base }

    its(:name)          { should eql("TestModelMapper") }
    its(:model)         { should be(model) }
    its(:relation_name) { should eql("test_models") }
    its(:repository)    { should be(repository) }
  end

  context "with a block" do
    let(:block) { Proc.new { relation_name(:foo) } }

    it "instance evals the block" do
      subject.relation_name.should be(:foo)
    end
  end
end
