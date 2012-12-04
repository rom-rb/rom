require 'spec_helper'

describe Relation::Mapper, '#rename' do
  subject { object.rename(aliases) }

  let(:object)   { mock_mapper(model).new(relation) }
  let(:relation) { mock('relation') }
  let(:rename)   { mock('rename') }
  let(:model)    { mock_model(:User) }
  let(:aliases)  { mock('aliases') }

  before do
    relation.should_receive(:rename).with(aliases).and_return(rename)
  end

  it { should be_instance_of(object.class) }

  its(:relation)   { should be(rename) }
  its(:attributes) { should be(object.attributes) }
end
