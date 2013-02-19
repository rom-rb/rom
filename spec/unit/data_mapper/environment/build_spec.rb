require 'spec_helper'

describe Environment, '#build' do
  subject { object.build(model, repository) }

  let(:object)     { described_class.coerce(:test => 'in_memory://test') }
  let(:model)      { mock_model('User') }
  let(:repository) { :test }
  let(:mapper)     { mock('mapper') }

  it 'builds mapper class' do
    subject.should be < Relation::Mapper
  end

  it "uses the correct repository" do
    subject.repository.should eql(repository)
  end
end
