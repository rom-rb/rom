require 'spec_helper'

describe Relation::Mapper, '#relation_name' do
  subject { object.relation_name }

  let(:object)   { mock_mapper(model).new(relation) }
  let(:relation) { mock('relation') }
  let(:model)    { mock_model(:User) }

  it 'delegates to self.class' do
    subject.should be(:users)
  end
end
