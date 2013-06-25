require 'spec_helper'

describe Mapper, '#identity' do
  subject { mapper.identity(object) }

  include_context 'Mapper'

  before do
    stub(dumper).identity(object) { [1] }
  end

  it { should eq([1]) }
end
