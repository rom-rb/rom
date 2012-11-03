require 'spec_helper'

describe Mapper::Relation, '#find' do
  subject { object.find(options) }

  let(:object)      { mock_mapper(model).new(relation) }
  let(:relation)    { mock('relation') }
  let(:restriction) { mock('restriction') }
  let(:model)       { mock_model(:User) }
  let(:query)       { {} }
  let(:options)     { {} }

  before do
    Query.should_receive(:new).with(options, object.attributes).and_return(query)
    relation.should_receive(:restrict).with(query).and_return(restriction)
  end

  it { should be_instance_of(object.class) }

  its(:relation)   { should be(restriction) }
  its(:attributes) { should be(object.attributes) }
end
