require 'spec_helper'

describe Relation::Mapper, '#relation_name' do
  subject { object.relation_name }

  let(:object)   { mock_mapper(model).new(relation) }
  let(:relation) { mock('relation') }
  let(:model)    { mock_model(:User) }

  before do
    # received during call to mock_mapper
    described_class.should_receive(:relation_name)
  end

  it 'delegates to self.class' do
    described_class.should_receive(:relation_name).and_return(:users)
    subject.should be(:users)
  end
end
