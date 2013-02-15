require 'spec_helper'

describe Relation::Mapper, '#join' do
  subject { object.join(other) }

  let(:object)         { mock_mapper(model).new(DM_ENV, relation) }
  let(:other)          { mock_mapper(model).new(DM_ENV, other_relation) }
  let(:relation)       { mock('relation') }
  let(:other_relation) { mock('other_relation') }
  let(:joined)         { mock('joined_relation') }
  let(:model)          { mock_model(:User) }

  before do
    relation.should_receive(:join).with(other_relation).and_return(joined)
  end

  it { should be_instance_of(object.class) }

  its(:relation)   { should be(joined) }
  its(:attributes) { should be(object.attributes) }
end
