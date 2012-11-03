require 'spec_helper'

describe Mapper::Relation, '#sort_by' do
  subject { object.sort_by(*names, &block) }

  let(:object)   { mock_mapper(model).new(relation) }
  let(:model)    { mock_model(:User) }
  let(:relation) { mock('relation') }
  let(:sorted)   { mock('sorted') }
  let(:block)    { Proc.new {} }
  let(:names)    { [ :foo, :bar ] }

  before do
    relation.should_receive(:sort_by).with(*names, &block).and_return(sorted)
  end

  it { should be_instance_of(object.class) }

  its(:relation)   { should be(sorted) }
  its(:attributes) { should be(object.attributes) }
end
