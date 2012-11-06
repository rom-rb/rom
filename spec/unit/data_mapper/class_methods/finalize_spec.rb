require 'spec_helper'

describe DataMapper, '.finalize' do
  subject { DataMapper.finalize }

  context 'when not yet finalized' do
    before { Finalizer.should_receive(:call) }

    it { should be(DataMapper) }
  end

  context 'when already finalized' do
    before do
      DataMapper.instance_variable_set(:@finalized, false)
      Finalizer.should_receive(:call).once
      DataMapper.finalize
    end

    it { should be(DataMapper) }
  end
end
