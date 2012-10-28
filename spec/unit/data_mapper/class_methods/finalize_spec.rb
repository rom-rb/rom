require 'spec_helper'

describe DataMapper, '.finalize' do
  subject { DataMapper.finalize }

  before { Finalizer.should_receive(:run) }

  it { should be(DataMapper) }
end
