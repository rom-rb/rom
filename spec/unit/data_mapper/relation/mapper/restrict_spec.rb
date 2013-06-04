require 'spec_helper'

describe Relation::Mapper, '#restrict' do
  subject { object.restrict(&block) }

  let(:object)      { mock_mapper(model).new(ROM_ENV, relation) }
  let(:relation)    { mock('relation') }
  let(:restriction) { mock('restriction') }
  let(:model)       { mock_model(:User) }
  let(:block)       { Proc.new {} }

  before do
    relation.should_receive(:restrict).with(&block).and_return(restriction)
  end

  it { should be_instance_of(object.class) }

  its(:relation)   { should be(restriction) }
  its(:attributes) { should be(object.attributes) }
end
