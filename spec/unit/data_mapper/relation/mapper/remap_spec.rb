require 'spec_helper'

describe Relation::Mapper, '#remap' do
  subject { object.remap(aliases) }

  let(:object)     { mock_mapper(model, attributes).new(ROM_ENV, relation) }
  let(:model)      { mock_model(:User) }
  let(:attributes) { [ mock_attribute(:id, Integer) ] }
  let(:relation)   { mock('relation') }
  let(:aliases)    { { :id => :user_id } }

  it 'does not change the number of attributes' do
    subject.attributes.count.should == 1
  end

  it 'returns a new instance with aliased attributes' do
    subject.attributes[:id].field.should be(:user_id)
  end
end
