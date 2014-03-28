# encoding: utf-8

require 'spec_helper'

describe Mapper, '#dump' do
  include_context 'Mapper'

  it 'dumps the object into data tuple' do
    expect(mapper.dump(object)).to eql(data)
  end
end
