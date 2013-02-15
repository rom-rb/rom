require 'spec_helper'

describe Relation::Mapper, '#relations' do
  subject { object.relations }

  let(:object)    { described_class.new(DM_ENV, relation) }
  let(:relation)  { mock_relation('relation') }
  let(:relations) { mock('relations') }

  it 'delegates to self.class' do
    described_class.should_receive(:relations).and_return(relations)
    subject.should be(relations)
  end
end
