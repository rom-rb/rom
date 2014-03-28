# encoding: utf-8

require 'spec_helper'

describe Mapper, '#identity' do
  subject { mapper.identity(object) }

  include_context 'Mapper'

  it { should eq([1]) }
end
