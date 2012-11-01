require 'spec_helper'

describe Mapper, '#relations' do
  subject { object.relations }

  let(:object)    { described_class.new }
  let(:relations) { mock('relations') }

  it 'delegates to self.class' do
    described_class.should_receive(:relations).and_return(relations)
    subject.should be(relations)
  end
end
