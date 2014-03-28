# encoding: utf-8

require 'spec_helper'

describe Mapper, '#identity_from_tuple' do
  subject { mapper.identity_from_tuple(tuple) }

  include_context 'Mapper'

  it { should eq([1]) }
end
