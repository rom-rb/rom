require 'spec_helper'

describe Environment, '#finalize' do
  subject { object.finalize }

  let(:object) { described_class.coerce(:test => 'in_memory://test') }
  let(:uri)    { 'in_memory://test' }

  before do
    Finalizer.should_receive(:call).with(object)
  end

  it { should be(object) }
end
