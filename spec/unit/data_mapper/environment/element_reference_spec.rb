require 'spec_helper'

describe Environment, '#[]' do
  subject { object[model] }

  let(:object)   { described_class.new(registry) }
  let(:registry) { mock('registry') }
  let(:model)    { mock('model') }
  let(:mapper)   { mock('mapper') }

  it 'delegates to registry' do
    registry.should_receive(:[]).with(model).and_return(mapper)
    subject.should be(mapper)
  end
end
