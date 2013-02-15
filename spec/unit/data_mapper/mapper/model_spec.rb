require 'spec_helper'

describe Mapper, '#model' do
  subject { object.model }

  let(:object) { described_class.new(DM_ENV) }
  let(:model)  { mock('model') }

  it 'delegates to self.class' do
    described_class.should_receive(:model).and_return(model)
    subject.should be(model)
  end
end
