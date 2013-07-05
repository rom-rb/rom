require 'spec_helper'

describe Mapper, '#identity_from_tuple' do
  subject { mapper.identity_from_tuple(tuple) }

  include_context 'Mapper'

  before do
    stub(loader).identity(tuple) { [1] }
  end

  it { should eq([1]) }
end
