# encoding: utf-8

require 'spec_helper'

describe Mapper, '#load' do
  include_context 'Mapper'

  it 'loads the tuple into model' do
    expect(mapper.load(tuple)).to eql(object)
  end
end
