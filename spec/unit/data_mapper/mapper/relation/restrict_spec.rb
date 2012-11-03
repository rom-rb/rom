require 'spec_helper'

describe Mapper::Relation, '#restrict' do
  subject { object.restrict(&block) }

  let(:object)      { mock_mapper(model).new(relation) }
  let(:relation)    { mock('relation') }
  let(:restriction) { mock('restriction') }
  let(:model)       { mock_model(:User) }
  let(:block)       { Proc.new {} }

  before do
    relation.should_receive(:restrict).with(&block).and_return(restriction)
  end

  it { should be_instance_of(object.class) }

  its(:relation) { should be(restriction) }
end
