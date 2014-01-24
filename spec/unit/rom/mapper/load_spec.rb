# encoding: utf-8

require 'spec_helper'

describe Mapper, '#load' do
  include_context 'Mapper'

  it 'loads the tuple into model' do
    stub(loader).call(tuple) { object }

    expect(mapper.load(tuple)).to be(object)

    loader.should have_received.call(tuple)
  end
end
