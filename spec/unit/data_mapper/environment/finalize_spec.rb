require 'spec_helper'

describe Environment, '#finalize' do
  subject { object.finalize }

  let(:object) { described_class.new }

  before do
    Finalizer.should_receive(:call).with(object)
  end

  it { should be(object) }
end
