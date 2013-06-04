require 'spec_helper'

describe Relation::Mapper, '#sort_by' do
  subject { object.sort_by(*names, &block) }

  let(:object)   { mock_mapper(model).new(ROM_ENV, relation) }
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
