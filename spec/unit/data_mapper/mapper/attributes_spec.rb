require 'spec_helper'

describe Mapper, '#attributes' do
  subject { object.attributes }

  let(:object)     { described_class.new }
  let(:attributes) { mock('attributes') }

  it 'delegates to self.class' do
    described_class.should_receive(:attributes).and_return(attributes)
    subject.should be(attributes)
  end
end
