require 'spec_helper'

describe DataMapper::Mapper, '.finalize' do
  subject { described_class.finalize }

  it { should be(described_class) }
end
