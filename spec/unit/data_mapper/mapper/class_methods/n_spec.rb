require 'spec_helper'

describe Mapper, '.n' do
  subject { described_class.n }

  it { should be(DataMapper::Infinity) }
end
